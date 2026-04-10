describe("table module", function()
  local g

  setup(function()
    g = Glu("Glu")
  end)

  -- ========================================================================
  -- Type detection
  -- ========================================================================

  describe("indexed", function()
    it("should return true for sequential integer-keyed tables", function()
      assert.is_true(g.table.indexed({1, 2, 3}))
    end)

    it("should return false for associative tables", function()
      assert.is_false(g.table.indexed({a = 1, b = 2}))
    end)

    it("should return true for empty table", function()
      assert.is_true(g.table.indexed({}))
    end)

    it("should return false for mixed tables", function()
      assert.is_false(g.table.indexed({1, 2, a = 3}))
    end)

    it("should error on non-table argument", function()
      assert.has_error(function()
        g.table.indexed("hello")
      end)
    end)
  end)

  describe("associative", function()
    it("should return true for string-keyed tables", function()
      assert.is_true(g.table.associative({a = 1, b = 2}))
    end)

    it("should return false for indexed tables", function()
      assert.is_false(g.table.associative({1, 2, 3}))
    end)

    it("should return false for empty table", function()
      assert.is_false(g.table.associative({}))
    end)

    it("should return true for mixed tables", function()
      assert.is_true(g.table.associative({1, 2, a = 3}))
    end)
  end)

  describe("object", function()
    it("should return true when object field is true", function()
      assert.is_true(g.table.object({object = true}))
    end)

    it("should return false when object field is absent", function()
      assert.is_false(g.table.object({a = 1}))
    end)

    it("should return false when object field is false", function()
      assert.is_false(g.table.object({object = false}))
    end)
  end)

  -- ========================================================================
  -- Casting and construction
  -- ========================================================================

  describe("n_cast", function()
    it("should return an indexed table as-is", function()
      local t = {1, 2, 3}
      local result = g.table.n_cast(t)
      assert.are.same({1, 2, 3}, result)
    end)

    it("should wrap a single value in a table", function()
      local result = g.table.n_cast("hello")
      assert.are.same({"hello"}, result)
    end)

    it("should wrap multiple values in a table", function()
      local result = g.table.n_cast(1, 2, 3)
      assert.are.same({1, 2, 3}, result)
    end)

    it("should wrap an associative table in a table", function()
      local assoc = {a = 1}
      local result = g.table.n_cast(assoc)
      assert.are.equal(1, #result)
      assert.are.same(assoc, result[1])
    end)
  end)

  describe("allocate", function()
    it("should create key-value pairs from two tables", function()
      local result = g.table.allocate({"a", "b", "c"}, {1, 2, 3})
      assert.are.equal(1, result.a)
      assert.are.equal(2, result.b)
      assert.are.equal(3, result.c)
    end)

    it("should fill all keys with a scalar value", function()
      local result = g.table.allocate({"a", "b", "c"}, true)
      assert.is_true(result.a)
      assert.is_true(result.b)
      assert.is_true(result.c)
    end)

    it("should use a function to generate values", function()
      local result = g.table.allocate({"a", "b", "c"}, function(i, k) return i end)
      assert.are.equal(1, result.a)
      assert.are.equal(2, result.b)
      assert.are.equal(3, result.c)
    end)

    it("should error when source and spec tables have different lengths", function()
      assert.has_error(function()
        g.table.allocate({"a", "b"}, {1, 2, 3})
      end)
    end)

    it("should error on empty source", function()
      assert.has_error(function()
        g.table.allocate({}, {})
      end)
    end)
  end)

  describe("new_weak", function()
    it("should create a weak-valued table by default", function()
      local t = g.table.new_weak()
      local mt = getmetatable(t)
      assert.are.equal("v", mt.__mode)
    end)

    it("should create a weak-keyed table", function()
      local t = g.table.new_weak("k")
      local mt = getmetatable(t)
      assert.are.equal("k", mt.__mode)
    end)

    it("should create a table with both weak keys and values", function()
      local t = g.table.new_weak("kv")
      local mt = getmetatable(t)
      assert.are.equal("kv", mt.__mode)
    end)
  end)

  describe("weak", function()
    it("should return true for a weak table", function()
      local t = setmetatable({}, {__mode = "v"})
      assert.is_true(g.table.weak(t))
    end)

    it("should return false for a normal table", function()
      assert.is_false(g.table.weak({1, 2, 3}))
    end)
  end)

  -- ========================================================================
  -- Extraction and transformation
  -- ========================================================================

  describe("values", function()
    it("should return all values from an associative table", function()
      local result = g.table.values({a = 1, b = 2})
      table.sort(result)
      assert.are.same({1, 2}, result)
    end)

    it("should return all values from an indexed table", function()
      local result = g.table.values({10, 20, 30})
      assert.are.same({10, 20, 30}, result)
    end)

    it("should return empty for empty table", function()
      assert.are.same({}, g.table.values({}))
    end)
  end)

  describe("map", function()
    it("should transform table values", function()
      local result = g.table.map({a = 1, b = 2}, function(k, v) return v * 2 end)
      assert.are.equal(2, result.a)
      assert.are.equal(4, result.b)
    end)

    it("should pass extra args to the function", function()
      local result = g.table.map({1, 2}, function(k, v, mult) return v * mult end, 10)
      assert.are.same({10, 20}, result)
    end)

    it("should handle empty table", function()
      local result = g.table.map({}, function(k, v) return v end)
      assert.are.same({}, result)
    end)
  end)

  describe("reduce", function()
    it("should reduce a table to a single value", function()
      local result = g.table.reduce({1, 2, 3, 4}, function(acc, v) return acc + v end, 0)
      assert.are.equal(10, result)
    end)

    it("should pass key to the function", function()
      local keys = {}
      g.table.reduce({10, 20}, function(acc, v, k) keys[#keys + 1] = k; return acc end, 0)
      table.sort(keys)
      assert.are.same({1, 2}, keys)
    end)

    it("should handle single element table", function()
      local result = g.table.reduce({5}, function(acc, v) return acc + v end, 0)
      assert.are.equal(5, result)
    end)
  end)

  describe("n_uniform", function()
    it("should return true when all elements are the same type", function()
      assert.is_true(g.table.n_uniform({1, 2, 3}))
    end)

    it("should return false when elements are mixed types", function()
      assert.is_false(g.table.n_uniform({1, "two", 3}))
    end)

    it("should check against a specified type", function()
      assert.is_true(g.table.n_uniform({"a", "b", "c"}, "string"))
    end)

    it("should return false when type doesn't match specified", function()
      assert.is_false(g.table.n_uniform({1, 2, 3}, "string"))
    end)

    it("should return true for single-element table", function()
      assert.is_true(g.table.n_uniform({1}))
    end)
  end)

  describe("n_distinct", function()
    it("should return distinct values", function()
      local result = g.table.n_distinct({1, 2, 2, 3, 3, 3})
      assert.are.same({1, 2, 3}, result)
    end)

    it("should preserve order of first occurrence", function()
      local result = g.table.n_distinct({3, 1, 2, 1, 3})
      assert.are.same({3, 1, 2}, result)
    end)

    it("should handle already-unique table", function()
      local result = g.table.n_distinct({1, 2, 3})
      assert.are.same({1, 2, 3}, result)
    end)

    it("should handle single element", function()
      local result = g.table.n_distinct({5})
      assert.are.same({5}, result)
    end)
  end)

  -- ========================================================================
  -- Stack/queue operations
  -- ========================================================================

  describe("push and pop", function()
    it("should push to end and pop from end", function()
      local t = {1, 2, 3}
      g.table.push(t, 4)
      assert.are.same({1, 2, 3, 4}, t)
      local val = g.table.pop(t)
      assert.are.equal(4, val)
      assert.are.same({1, 2, 3}, t)
    end)

    it("should return new length from push", function()
      local t = {1, 2}
      local len = g.table.push(t, 3)
      assert.are.equal(3, len)
    end)

    it("should return nil when popping empty table", function()
      local t = {}
      local val = g.table.pop(t)
      assert.is_nil(val)
    end)
  end)

  describe("shift and unshift", function()
    it("should unshift to front and shift from front", function()
      local t = {1, 2, 3}
      g.table.unshift(t, 0)
      assert.are.same({0, 1, 2, 3}, t)
      local val = g.table.shift(t)
      assert.are.equal(0, val)
      assert.are.same({1, 2, 3}, t)
    end)

    it("should return new length from unshift", function()
      local t = {1}
      local len = g.table.unshift(t, 0)
      assert.are.equal(2, len)
    end)

    it("should return nil when shifting empty table", function()
      local t = {}
      local val = g.table.shift(t)
      assert.is_nil(val)
    end)
  end)

  -- ========================================================================
  -- Slicing, removing, chunking
  -- ========================================================================

  describe("slice", function()
    it("should return a slice of the table", function()
      local result = g.table.slice({1, 2, 3, 4, 5}, 2, 4)
      assert.are.same({2, 3, 4}, result)
    end)

    it("should slice to end when stop is omitted", function()
      local result = g.table.slice({1, 2, 3, 4, 5}, 3)
      assert.are.same({3, 4, 5}, result)
    end)

    it("should return single element when start equals stop", function()
      local result = g.table.slice({10, 20, 30}, 2, 2)
      assert.are.same({20}, result)
    end)

    it("should return entire table when slicing from 1", function()
      local result = g.table.slice({1, 2, 3}, 1)
      assert.are.same({1, 2, 3}, result)
    end)
  end)

  describe("remove", function()
    it("should remove a single element", function()
      local t = {1, 2, 3, 4, 5}
      local remaining, snipped = g.table.remove(t, 3)
      assert.are.same({1, 2, 4, 5}, remaining)
      assert.are.same({3}, snipped)
    end)

    it("should remove a range of elements", function()
      local t = {1, 2, 3, 4, 5}
      local remaining, snipped = g.table.remove(t, 2, 4)
      assert.are.same({1, 5}, remaining)
      assert.are.same({2, 3, 4}, snipped)
    end)

    it("should remove the first element", function()
      local t = {10, 20, 30}
      local remaining, snipped = g.table.remove(t, 1, 1)
      assert.are.same({20, 30}, remaining)
      assert.are.same({10}, snipped)
    end)

    it("should remove the last element", function()
      local t = {10, 20, 30}
      local remaining, snipped = g.table.remove(t, 3, 3)
      assert.are.same({10, 20}, remaining)
      assert.are.same({30}, snipped)
    end)
  end)

  describe("chunk", function()
    it("should split into even chunks", function()
      local result = g.table.chunk({1, 2, 3, 4}, 2)
      assert.are.same({{1, 2}, {3, 4}}, result)
    end)

    it("should handle uneven last chunk", function()
      local result = g.table.chunk({1, 2, 3, 4, 5}, 2)
      assert.are.same({{1, 2}, {3, 4}, {5}}, result)
    end)

    it("should handle size of 1", function()
      local result = g.table.chunk({1, 2, 3}, 1)
      assert.are.same({{1}, {2}, {3}}, result)
    end)

    it("should handle size larger than table", function()
      local result = g.table.chunk({1, 2}, 5)
      assert.are.same({{1, 2}}, result)
    end)
  end)

  -- ========================================================================
  -- Concatenation and merging
  -- ========================================================================

  describe("concat", function()
    it("should concatenate tables", function()
      local t = {1, 2}
      g.table.concat(t, {3, 4}, {5})
      assert.are.same({1, 2, 3, 4, 5}, t)
    end)

    it("should handle scalar values", function()
      local t = {1, 2}
      g.table.concat(t, 3)
      assert.are.same({1, 2, 3}, t)
    end)

    it("should handle empty source tables", function()
      local t = {1, 2}
      g.table.concat(t, {})
      assert.are.same({1, 2}, t)
    end)

    it("should handle mixed table and scalar args", function()
      local t = {}
      g.table.concat(t, 1, {2, 3}, 4)
      assert.are.same({1, 2, 3, 4}, t)
    end)
  end)

  describe("add", function()
    it("should merge associative tables", function()
      local t = {a = 1}
      g.table.add(t, {b = 2, c = 3})
      assert.are.equal(1, t.a)
      assert.are.equal(2, t.b)
      assert.are.equal(3, t.c)
    end)

    it("should overwrite existing keys", function()
      local t = {a = 1, b = 2}
      g.table.add(t, {b = 99})
      assert.are.equal(99, t.b)
    end)
  end)

  describe("n_add", function()
    it("should append to end by default", function()
      local t = {1, 2, 3}
      g.table.n_add(t, {4, 5})
      assert.are.same({1, 2, 3, 4, 5}, t)
    end)

    it("should insert at specified index", function()
      local t = {1, 4, 5}
      g.table.n_add(t, {2, 3}, 2)
      assert.are.same({1, 2, 3, 4, 5}, t)
    end)

    it("should insert at beginning", function()
      local t = {3, 4}
      g.table.n_add(t, {1, 2}, 1)
      assert.are.same({1, 2, 3, 4}, t)
    end)
  end)

  -- ========================================================================
  -- Drop operations
  -- ========================================================================

  describe("drop", function()
    it("should drop first n elements", function()
      local result = g.table.drop({1, 2, 3, 4, 5}, 2)
      assert.are.same({3, 4, 5}, result)
    end)

    it("should drop 1 element", function()
      local result = g.table.drop({10, 20, 30}, 1)
      assert.are.same({20, 30}, result)
    end)
  end)

  describe("drop_right", function()
    it("should drop last n elements", function()
      local result = g.table.drop_right({1, 2, 3, 4, 5}, 2)
      assert.are.same({1, 2, 3}, result)
    end)

    it("should drop 1 element from end", function()
      local result = g.table.drop_right({10, 20, 30}, 1)
      assert.are.same({10, 20}, result)
    end)
  end)

  -- ========================================================================
  -- Fill
  -- ========================================================================

  describe("fill", function()
    it("should fill a range with a value", function()
      local t = {1, 2, 3, 4, 5}
      g.table.fill(t, 0, 2, 4)
      assert.are.same({1, 0, 0, 0, 5}, t)
    end)

    it("should fill entire table when no range specified", function()
      local t = {1, 2, 3}
      g.table.fill(t, 0)
      assert.are.same({0, 0, 0}, t)
    end)

    it("should fill from start to end of table", function()
      local t = {1, 2, 3, 4}
      g.table.fill(t, 9, 3)
      assert.are.same({1, 2, 9, 9}, t)
    end)
  end)

  -- ========================================================================
  -- Search operations
  -- ========================================================================

  describe("find", function()
    it("should find the first matching index", function()
      local result = g.table.find({10, 20, 30}, function(i, v) return v > 15 end)
      assert.are.equal(2, result)
    end)

    it("should return nil when not found", function()
      local result = g.table.find({10, 20, 30}, function(i, v) return v > 50 end)
      assert.is_nil(result)
    end)

    it("should find first element", function()
      local result = g.table.find({10, 20, 30}, function(i, v) return v == 10 end)
      assert.are.equal(1, result)
    end)
  end)

  describe("find_last", function()
    it("should find the last matching index", function()
      local result = g.table.find_last({10, 20, 30}, function(i, v) return v > 15 end)
      assert.are.equal(3, result)
    end)

    it("should return nil when not found", function()
      local result = g.table.find_last({10, 20, 30}, function(i, v) return v > 50 end)
      assert.is_nil(result)
    end)
  end)

  describe("includes", function()
    it("should return true when value is present", function()
      assert.is_true(g.table.includes({1, 2, 3}, 2))
    end)

    it("should return false when value is absent", function()
      assert.is_false(g.table.includes({1, 2, 3}, 4))
    end)

    it("should match by type", function()
      assert.is_false(g.table.includes({1, 2, 3}, "2"))
    end)
  end)

  -- ========================================================================
  -- Reordering and deduplication
  -- ========================================================================

  describe("reverse", function()
    it("should reverse the table in place", function()
      local t = {1, 2, 3, 4, 5}
      g.table.reverse(t)
      assert.are.same({5, 4, 3, 2, 1}, t)
    end)

    it("should handle even-length table", function()
      local t = {1, 2, 3, 4}
      g.table.reverse(t)
      assert.are.same({4, 3, 2, 1}, t)
    end)

    it("should handle single element", function()
      local t = {1}
      g.table.reverse(t)
      assert.are.same({1}, t)
    end)
  end)

  describe("uniq", function()
    it("should remove duplicate values", function()
      local t = {1, 2, 2, 3, 3, 3}
      g.table.uniq(t)
      assert.are.same({1, 2, 3}, t)
    end)

    it("should handle already-unique table", function()
      local t = {1, 2, 3}
      g.table.uniq(t)
      assert.are.same({1, 2, 3}, t)
    end)

    it("should handle single element", function()
      local t = {5}
      g.table.uniq(t)
      assert.are.same({5}, t)
    end)

    it("should preserve first occurrence order", function()
      local t = {3, 1, 2, 1, 3}
      g.table.uniq(t)
      assert.are.same({3, 1, 2}, t)
    end)
  end)

  describe("pull", function()
    it("should remove specified values", function()
      local t = {1, 2, 3, 4, 5}
      g.table.pull(t, 2, 4)
      assert.are.same({1, 3, 5}, t)
    end)

    it("should handle values not in table", function()
      local t = {1, 2, 3}
      g.table.pull(t, 99)
      assert.are.same({1, 2, 3}, t)
    end)

    it("should return table unchanged when no args", function()
      local t = {1, 2, 3}
      g.table.pull(t)
      assert.are.same({1, 2, 3}, t)
    end)

    it("should remove all occurrences", function()
      local t = {1, 2, 1, 2, 1}
      g.table.pull(t, 1)
      assert.are.same({2, 2}, t)
    end)
  end)

  -- ========================================================================
  -- Flattening
  -- ========================================================================

  describe("flatten", function()
    it("should flatten one level of nesting", function()
      local result = g.table.flatten({{1, 2}, {3, 4}, 5})
      assert.are.same({1, 2, 3, 4, 5}, result)
    end)

    it("should not flatten deeply nested tables", function()
      local result = g.table.flatten({{1, {2, 3}}, 4})
      assert.are.equal(3, #result)
      assert.are.equal(1, result[1])
      assert.are.same({2, 3}, result[2])
      assert.are.equal(4, result[3])
    end)

    it("should handle empty nested tables", function()
      local result = g.table.flatten({{}, {1}, {}})
      assert.are.same({1}, result)
    end)
  end)

  describe("flatten_deeply", function()
    it("should flatten all levels of nesting", function()
      local result = g.table.flatten_deeply({{1, {2, 3}}, {4}, 5})
      assert.are.same({1, 2, 3, 4, 5}, result)
    end)

    it("should handle deeply nested structures", function()
      local result = g.table.flatten_deeply({{{{{1}}}}})
      assert.are.same({1}, result)
    end)

    it("should handle already-flat table", function()
      local result = g.table.flatten_deeply({1, 2, 3})
      assert.are.same({1, 2, 3}, result)
    end)
  end)

  -- ========================================================================
  -- Zip / Unzip
  -- ========================================================================

  describe("zip", function()
    it("should zip multiple tables together", function()
      local result = g.table.zip({1, 2, 3}, {"a", "b", "c"})
      assert.are.same({{1, "a"}, {2, "b"}, {3, "c"}}, result)
    end)

    it("should zip three tables", function()
      local result = g.table.zip({1, 2}, {"a", "b"}, {true, false})
      assert.are.same({{1, "a", true}, {2, "b", false}}, result)
    end)

    it("should error on tables of different lengths", function()
      assert.has_error(function()
        g.table.zip({1, 2}, {3})
      end)
    end)
  end)

  describe("unzip", function()
    it("should unzip a table of pairs", function()
      local result = g.table.unzip({{1, "a"}, {2, "b"}, {3, "c"}})
      assert.are.same({{1, 2, 3}, {"a", "b", "c"}}, result)
    end)

    it("should unzip a table of triples", function()
      local result = g.table.unzip({{1, "a", true}, {2, "b", false}})
      assert.are.same({{1, 2}, {"a", "b"}, {true, false}}, result)
    end)

    it("should error on sub-tables of different lengths", function()
      assert.has_error(function()
        g.table.unzip({{1, 2}, {3}})
      end)
    end)
  end)

  -- ========================================================================
  -- Initial
  -- ========================================================================

  describe("initial", function()
    it("should return all but last element", function()
      local result = g.table.initial({1, 2, 3, 4})
      assert.are.same({1, 2, 3}, result)
    end)

    it("should return empty for single element", function()
      local result = g.table.initial({1})
      assert.are.same({}, result)
    end)
  end)

  -- ========================================================================
  -- Walking / iteration
  -- ========================================================================

  describe("walk", function()
    it("should iterate over indexed table", function()
      local values = {}
      for i, v in g.table.walk({10, 20, 30}) do
        values[#values + 1] = v
      end
      assert.are.same({10, 20, 30}, values)
    end)

    it("should provide correct indices", function()
      local indices = {}
      for i, v in g.table.walk({"a", "b", "c"}) do
        indices[#indices + 1] = i
      end
      assert.are.same({1, 2, 3}, indices)
    end)

    it("should handle empty table", function()
      local count = 0
      for _ in g.table.walk({}) do
        count = count + 1
      end
      assert.are.equal(0, count)
    end)
  end)

  -- ========================================================================
  -- Random selection
  -- ========================================================================

  describe("element_of", function()
    it("should return an element from the table", function()
      local t = {10, 20, 30}
      local result = g.table.element_of(t)
      assert.is_true(g.table.includes(t, result))
    end)

    it("should return the only element from single-element table", function()
      assert.are.equal(42, g.table.element_of({42}))
    end)
  end)

  describe("element_of_weighted", function()
    it("should return a key from the weighted table", function()
      local weights = {a = 10, b = 20, c = 30}
      local result = g.table.element_of_weighted(weights)
      assert.is_truthy(weights[result])
    end)

    it("should return the only key when one weight dominates", function()
      -- With weight 1000 vs 0, should always return "winner"
      -- (math.random(1000) will always be <= 1000)
      local result = g.table.element_of_weighted({winner = 1000})
      assert.are.equal("winner", result)
    end)
  end)

  -- ========================================================================
  -- Predicate combinators
  -- ========================================================================

  describe("all / some / none / one", function()
    it("all should return true when all match via function", function()
      assert.is_true(g.table.all({1, 1, 1}, function(v) return v == 1 end))
    end)

    it("all should return false when not all match via function", function()
      assert.is_false(g.table.all({1, 2, 1}, function(v) return v == 1 end))
    end)

    it("some should return true when at least one matches via function", function()
      assert.is_true(g.table.some({1, 2, 3}, function(v) return v == 2 end))
    end)

    it("some should return false when none match", function()
      assert.is_false(g.table.some({1, 2, 3}, function(v) return v == 4 end))
    end)

    it("none should return true when nothing matches via function", function()
      assert.is_true(g.table.none({1, 2, 3}, function(v) return v == 4 end))
    end)

    it("none should return false when something matches", function()
      assert.is_false(g.table.none({1, 2, 3}, function(v) return v == 2 end))
    end)

    it("one should return true when exactly one matches via function", function()
      assert.is_true(g.table.one({1, 2, 3}, function(v) return v == 2 end))
    end)

    it("one should return false when more than one matches via function", function()
      assert.is_false(g.table.one({1, 2, 2}, function(v) return v == 2 end))
    end)

    it("one should return false when none match", function()
      assert.is_false(g.table.one({1, 2, 3}, function(v) return v == 4 end))
    end)

    it("all with scalar value should match", function()
      assert.is_true(g.table.all({1, 1, 1}, 1))
    end)

    it("none with scalar value should match", function()
      assert.is_true(g.table.none({1, 2, 3}, 4))
    end)

    it("some with scalar value should match", function()
      assert.is_true(g.table.some({1, 2, 3}, 2))
    end)

    it("one with scalar value should match", function()
      assert.is_true(g.table.one({1, 2, 3}, 2))
    end)
  end)

  describe("count", function()
    it("should count matching elements with function", function()
      assert.are.equal(2, g.table.count({1, 2, 3, 2}, function(v) return v == 2 end))
    end)

    it("should count matching elements with scalar", function()
      assert.are.equal(3, g.table.count({1, 1, 2, 1}, 1))
    end)

    it("should return 0 when none match", function()
      assert.are.equal(0, g.table.count({1, 2, 3}, 4))
    end)
  end)

  -- ========================================================================
  -- Sorting
  -- ========================================================================

  describe("natural_sort", function()
    it("should sort strings with embedded numbers naturally", function()
      local result = g.table.natural_sort({"file10", "file2", "file1"})
      assert.are.same({"file1", "file2", "file10"}, result)
    end)

    it("should not modify the original table", function()
      local t = {"b", "a", "c"}
      g.table.natural_sort(t)
      assert.are.same({"b", "a", "c"}, t)
    end)

    it("should sort purely alphabetical strings", function()
      local result = g.table.natural_sort({"banana", "apple", "cherry"})
      assert.are.same({"apple", "banana", "cherry"}, result)
    end)
  end)

  describe("sort", function()
    it("should sort with custom comparator", function()
      local t = {3, 1, 2}
      g.table.sort(t, function(a, b) return a < b end)
      assert.are.same({1, 2, 3}, t)
    end)

    it("should fall back to natural_sort without comparator", function()
      local result = g.table.sort({"b2", "b10", "b1"})
      assert.are.same({"b1", "b2", "b10"}, result)
    end)
  end)

  -- ========================================================================
  -- Introspection (functions/methods/properties)
  -- These require objects with metatables, so we test basic usage.
  -- ========================================================================

  describe("functions / methods", function()
    it("should return function keys from an object", function()
      local obj = {object = true, foo = function() end, bar = function() end, baz = 42}
      local result = g.table.functions(obj)
      table.sort(result)
      assert.is_true(g.table.includes(result, "foo"))
      assert.is_true(g.table.includes(result, "bar"))
      assert.is_false(g.table.includes(result, "baz"))
    end)

    it("methods should be an alias for functions", function()
      local obj = {object = true, fn = function() end}
      local from_functions = g.table.functions(obj)
      local from_methods = g.table.methods(obj)
      assert.are.same(from_functions, from_methods)
    end)
  end)

  describe("properties", function()
    it("should return non-function keys from an object", function()
      local obj = {object = true, foo = function() end, name = "test", count = 42}
      local result = g.table.properties(obj)
      assert.is_true(g.table.includes(result, "name"))
      assert.is_true(g.table.includes(result, "count"))
      assert.is_true(g.table.includes(result, "object"))
      assert.is_false(g.table.includes(result, "foo"))
    end)
  end)
end)
