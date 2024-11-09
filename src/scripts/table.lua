local TableClass = Glu.glass.register({
  name = "table",
  class_name = "TableClass",
  dependencies = { "valid" },
  setup = function(___, self)
    --- Casts a value to an indexed table if it is not already one.
    ---
    --- @param ...any - The value to cast.
    --- @return table - A new indexed table with the value or the value itself if it is already indexed.
    ---
    --- @example
    --- ```lua
    --- table.n_cast(1)
    --- -- {1}
    --- ```
    function self.n_cast(...)
      if type(...) == "table" and self.indexed(...) then
        return ...
      end

      return { ... }
    end

    self.assure_indexed = self.n_cast

    --- Takes a table and a function and returns a new table with the function
    --- applied to each element of the original table.
    --- @param t table - The table to map over.
    --- @param fn function - The function to apply to each element of the table.
    --- @param ... any - Additional arguments to pass to the function.
    --- @return table - A new table with the function applied to each element.
    --- @example
    --- ```lua
    --- table.map({1, 2, 3}, function(k, v) return v * 2 end)
      --- -- {2, 4, 6}
    --- ```
    function self.map(t, fn, ...)
      ___.valid.type(t, "table", 1, false)
      ___.valid.type(fn, "function", 2, false)

      local result = {}
      for k, v in pairs(t) do
        result[k] = fn(k, v, ...)
      end
      return result
    end

    --- Takes a table and returns a new table with the values of the original table.
    --- @param t table - The table to get the values from.
    --- @return table - A new table with the values of the original table.
    --- @example
    --- ```lua
    --- table.values({a = 1, b = 2, c = 3})
    --- -- {1, 2, 3}
    --- ```
    function self.values(t)
      ___.valid.type(t, "table", 1, false)

      local result = {}
        for _, v in pairs(t) do
          result[#result + 1] = v
        end
        return result
      end

    --- Checks if all elements in the table are of the same type. If type is not
    --- provided, it will check if all elements are of the same type as the first
    --- element in the table.
    --- @param t table - The table to check.
    --- @param typ string|nil - The type to check for. (Optional)
    --- @return boolean - True if all elements are of the same type, false otherwise.
    --- @example
    --- ```lua
    --- table.n_uniform({1, 2, 3}, "number")
    --- -- true
    --- ```
    function self.n_uniform(t, typ)
      ___.valid.type(t, "table", 1, false)
      ___.valid.not_empty(t, 1, false)
      ___.valid.indexed(t, 1, false)
      ___.valid.type(typ, "string", 2, true)

      typ = typ or type(t[1])

      for _, v in pairs(t) do
        if type(v) ~= typ then
          return false
        end
      end

      return true
    end

    --- Takes a table and returns a new table with the distinct elements of the original table.
    --- @param t table - The table to get the distinct elements from.
    --- @return table - A new table with the distinct elements of the original table.
    --- @example
    --- ```lua
    --- table.n_distinct({1, 2, 2, 3, 4, 4, 5})
    --- -- {1, 2, 3, 4, 5}
    --- ```
    function self.n_distinct(t)
      ___.valid.indexed(t, 1, false)

      local result, seen = {}, {}
      for _, v in ipairs(t) do
        if not seen[v] then
          seen[v] = true
          result[#result + 1] = v
        end
      end
      return result
    end

    --- Removes and returns the last element of a table.
    --- @param t table - The table to pop the last element from.
    --- @return any - The last element of the table.
    --- @example
    --- ```lua
    --- table.pop({1, 2, 3})
    --- -- 3
    --- ```
    function self.pop(t)
      ___.valid.type(t, "table", 1, false)
      ___.valid.indexed(t, 1, false)
      return table.remove(t, #t)
    end

    --- Adds an element to the end of a table and returns the new length of the table.
    --- @param t table - The table to push the element to.
    --- @param v any - The element to push to the table.
    --- @return number - The new length of the table.
    --- @example
    --- ```lua
    --- table.push({1, 2, 3}, 4)
    --- -- 4
    --- ```
    function self.push(t, v)
      ___.valid.type(t, "table", 1, false)
      ___.valid.type(v, "any", 2, false)
      ___.valid.indexed(t, 1, false)
      table.insert(t, v)

      return #t
    end

    --- Adds an element to the beginning of a table and returns the new length of the table.
    --- @param t table - The table to unshift the element to.
    --- @param v any - The element to unshift to the table.
    --- @return number - The new length of the table.
    --- @example
    --- ```lua
    --- table.unshift({2, 3, 4}, 1)
    --- -- 4
    --- ```
    function self.unshift(t, v)
      ___.valid.type(t, "table", 1, false)
      ___.valid.type(v, "any", 2, false)
      ___.valid.indexed(t, 1, false)
      table.insert(t, 1, v)

      return #t
    end

    --- Removes and returns the first element of a table.
    --- @param t table - The table to shift the first element from.
    --- @return any - The first element of the table.
    --- @example
    --- ```lua
    --- table.shift({1, 2, 3})
    --- -- 1
    --- ```
    function self.shift(t)
      ___.valid.type(t, "table", 1, false)
      ___.valid.indexed(t, 1, false)
      return table.remove(t, 1)
    end

    --- Allocates a new table based on the source and spec. Essentially, it
    --- combines the spec, which can be an indexed table, a function, or a single
    --- value, with the source, which must be an indexed table.
    ---
    --- - If the spec is a table, it must have the same number of elements as the
    ---   source and each element will be mapped to the corresponding element in
    ---   the source.
    --- - If the spec is a function, it will be applied to each element of the
    ---   source.
    --- - Otherwise, if the spec is only a single value, it will be applied to
    ---   every element in the source.
    ---
    --- @param source table - The source table to allocate from.
    --- @param spec table|function|any - The spec to allocate the new table with.
    --- @return table - A new table allocated from the source and spec.
    --- @example
    --- ```lua
    --- table.allocate({"a", "b", "c"}, "x")
    --- -- {a = "x", b = "x", c = "x"}
    --- ```
    --- ```lua
    --- table.allocate({"a","b","c"}, {1, 2, 3})
    --- -- {a = 1, b = 2, c = 3}
    --- ```
    --- ```lua
    --- table.allocate({ "a", "b", "c" }, function(k, v)
    ---   return string.byte(v)
    --- end)
    --- -- {a = 97, b = 98, c = 99}
    --- ```
    function self.allocate(source, spec)
      local spec_type = type(spec)
      ___.valid.type(source, "table", 1, false)
      ___.valid.not_empty(source, 1, false)
      ___.valid.indexed(source, 1, false)
      if spec_type == ___.TYPE.TABLE then
        ___.valid.indexed(spec, 2, false)
        assert(#source == #spec, "Expected source and spec to have the same number of elements")
      elseif spec_type == ___.TYPE.FUNCTION then
        ___.valid.type(spec, "function", 2, false)
      end

      local result = {}

      if spec_type == ___.TYPE.TABLE then
        for i = 1, #spec do
          result[source[i]] = spec[i]
        end
      elseif spec_type == ___.TYPE.FUNCTION then
        for i = 1, #source do
          result[source[i]] = spec(i, source[i])
        end
      else
        for i = 1, #source do
          result[source[i]] = spec
        end
      end

      return result
    end

    --- Checks if a table is indexed (like an array).
    ---
    --- Returns true if the table is indexed (like an array).
    ---
    --- @param t table - The table to check.
    --- @return boolean - True if the table is indexed, false otherwise.
    --- @example
    --- ```lua
    --- table.indexed({1, 2, 3})
    --- -- true
    --- ```
    function self.indexed(t)
      ___.valid.type(t, "table", 1, false)

      local index = 1
      for k in pairs(t) do
        if k ~= index then
          return false
        end
        index = index + 1
      end
      return true
    end

    --- Checks if a table is associative (has non-integer keys).
    ---
    --- Returns true if the table is associative (has non-integer keys).
    ---
    --- @param t table - The table to check.
    --- @return boolean - True if the table is associative, false otherwise.
    --- @example
    --- ```lua
    --- table.associative({a = 1, b = 2, c = 3})
    --- -- true
    --- ```
    function self.associative(t)
      ___.valid.type(t, "table", 1, false)

      for k, _ in pairs(t) do
        if type(k) ~= "number" or k % 1 ~= 0 or k <= 0 then
            return true
        end
      end
      return false
    end

    --- Reduces a table to a single value using a function.
    --- @param t table - The table to reduce.
    --- @param fn function - The function to reduce the table with.
    --- @param initial any - The initial value to reduce the table with.
    --- @return any - The reduced value.
    --- @example
    --- ```lua
    --- table.reduce({1, 2, 3}, function(acc, v) return acc + v end, 0)
    --- -- 6
    --- ```
    function self.reduce(t, fn, initial)
      ___.valid.indexed(t, 1, false)
      ___.valid.type(fn, "function", 2, false)
      ___.valid.type(initial, "any", 3, false)

      local acc = initial
      for k, v in pairs(t) do
        acc = fn(acc, v, k)
      end
      return acc
    end

    --- Returns a slice of a table from the start index to the stop index. If the
    --- stop index is not provided, it will slice to the end of the table.
    ---
    --- @param t any - The table to slice.
    --- @param start number - The start index of the slice.
    --- @param stop number|nil - The stop index of the slice.
    --- @return table - A new table containing the slice of the original table.
    --- @example
    --- ```lua
    --- table.slice({1, 2, 3, 4, 5}, 2, 4)
    --- -- {2, 3, 4}
    --- ```
    --- ```lua
    --- table.slice({1, 2, 3, 4, 5}, 2)
    --- -- {2, 3, 4, 5}
    --- ```
    function self.slice(t, start, stop)
      ___.valid.indexed(t, 1, false)
      ___.valid.type(start, "number", 2, false)
      ___.valid.type(stop, "number", 3, true)
      ___.valid.test(start >= 1, 2, false)
      ___.valid.test(table.size(t) >= start, 2, false)
      ___.valid.test(stop and stop >= start, 3, true)

      if not stop then
        stop = #t
      end

      local result = {}
      for i = start, stop do
        result[#result + 1] = t[i]
      end
      return result
    end

    --- Removes and returns a slice of a table from the start index to the stop
    --- index. If the stop index is not provided, it will only remove the element
    --- at the start index. A second return value is also provided containing the
    --- removed slice.
    --- @param t table - The table to remove the slice from.
    --- @param start number - The start index of the slice.
    --- @param stop number|nil - The stop index of the slice.
    --- @return table - The original table with the slice removed.
    --- @return table - A new table containing the removed slice.
    --- @example
    --- ```lua
    --- table.remove({1, 2, 3, 4, 5}, 2, 4)
    --- -- {1, 5}
    --- -- {2, 3, 4}
    --- ```
    --- ```lua
    --- table.remove({1, 2, 3, 4, 5}, 2)
    --- -- {1, 3, 4, 5}
    --- -- {2}
    --- ```
    function self.remove(t, start, stop)
      ___.valid.indexed(t, 1, false)
      ___.valid.type(start, "number", 2, false)
      ___.valid.type(stop, "number", 3, true)
      ___.valid.test(start >= 1, 2, false)
      ___.valid.test(table.size(t) >= start, 2, false)
      ___.valid.test(stop and stop >= start, 3, true)

      local snipped = {}
      if not stop then stop = start end
      local count = stop - start + 1
      for i = 1, count do
        table.insert(snipped, table.remove(t, start))
      end
      return t, snipped
    end

    --- Returns a table of tables, each containing a slice of the original table
    --- of specified size. If there are not enough elements to fill the last
    --- chunk, the last chunk will contain the remaining elements.
    --- @param t table - The table to chunk.
    --- @param size number - The size of each chunk.
    --- @return table - A table of tables, each containing a slice of the original table.
    --- @example
    --- ```lua
    --- table.chunk({1, 2, 3, 4, 5}, 2)
    --- -- {{1, 2}, {3, 4}, {5}}
    --- ```
    function self.chunk(t, size)
      ___.valid.indexed(t, 1, false)
      ___.valid.type(size, "number", 2, false)

      local result = {}
      for i = 1, #t, size do
        result[#result + 1] = mod.slice(___, t, i, i + size - 1)
      end
      return result
    end

    --- Creates a new table by concatenating the original table with any
    --- additional arrays and/or values. If the arguments contains tables, they
    --- will be concatenated with the original table. Otherwise, the values will
    --- be added to the end of the original table.
    --- @param tbl table - The first table to concatenate.
    --- @param ... table|any - Additional tables and/or values to concatenate.
    --- @return table - A new table containing the concatenated tables.
    --- @example
    --- ```lua
    --- table.concat({1}, 2, {3}, {{4}})
    --- -- {1, 2, 3, {4}}
    --- ```
    function self.concat(tbl, ...)
      ___.valid.indexed(tbl, 1, false)

      local args = { ... }

      for _, tbl_value in ipairs(args) do
        if type(tbl_value) == "table" then
          for _, value in ipairs(tbl_value) do
            table.insert(tbl, value)
          end
        else
          table.insert(tbl, tbl_value)
        end
      end

      return tbl
    end

    --- Returns a new table with the first n elements removed.
    --- @param tbl table - The table to drop the first n elements from.
    --- @param n number - The number of elements to drop from the table.
    --- @return table - A new table with the first n elements removed.
    --- @example
    --- ```lua
    --- table.drop({1, 2, 3, 4, 5}, 3)
    --- -- {4, 5}
    --- ```
    function self.drop(tbl, n)
      ___.valid.indexed(tbl, 1, false)
      ___.valid.type(n, "number", 2, false)
      ___.valid.test(n >= 1, 2, false)
      return self.slice(___, tbl, n + 1)
    end

    --- Returns a new table with the last n elements removed.
    --- @param tbl table - The table to drop the last n elements from.
    --- @param n number - The number of elements to drop from the table.
    --- @return table - A new table with the last n elements removed.
    --- @example
    --- ```lua
    --- table.dropRight({1, 2, 3, 4, 5}, 3)
    --- -- {1, 2}
    --- ```
    function self.dropRight(tbl, n)
      ___.valid.indexed(tbl, 1, false)
      ___.valid.type(n, "number", 2, false)
      ___.valid.test(n >= 1, 2, false)
      return self.slice(___, tbl, 1, #tbl - n)
    end

    --- Fills a table with a value from the start index to the stop index. If the
    --- start index is not provided, it will fill from the beginning of the table.
    --- If the stop index is not provided, it will fill to the end of the table.
    ---
    --- *Note: Filling a table with nil will essentially render it "empty".*
    ---
    --- @param tbl table - The table to fill.
    --- @param value any - The value to fill the table with.
    --- @param start number|nil - The start index to fill the table with.
    --- @param stop number|nil - The stop index to fill the table with.
    --- @return table - The filled table.
    --- @example
    --- ```lua
    --- table.fill({1, 2, 3, 4, 5}, "x")
    --- -- {"x", "x", "x", "x", "x"}
    --- ```
    function self.fill(tbl, value, start, stop)
      ___.valid.indexed(tbl, 1, false)
      ___.valid.type(value, "any", 2, false)
      ___.valid.type(start, "number", 3, true)
      ___.valid.type(stop, "number", 4, true)
      ___.valid.test(start and start >= 1, value, 3, true)
      ___.valid.test(stop and stop >= start, value, 4, true)

      for i = start or 1, stop or #tbl do
        tbl[i] = value
      end
      return tbl
    end

    --- Returns the index of the first element in a table that satisfies a
    --- predicate function.
    --- @param tbl table - The table to find the index of the first element in.
    --- @param fn function - The predicate function to satisfy.
    --- @return number|nil - The index of the first element that satisfies the predicate function, or nil if no element satisfies the predicate.
    --- @example
    --- ```lua
    --- table.findIndex({1, 2, 3, 4, 5}, function(i, v) return v > 3 end)
    --- -- 4
    --- ```
    function self.find(tbl, fn)
      ___.valid.indexed(tbl, 1, false)
      ___.valid.type(fn, "function", 2, false)

      for i = 1, #tbl do
        if fn(i, tbl[i]) then
          return i
        end
      end
      return nil
    end

    --- Returns the index of the last element in a table that satisfies a
    --- predicate function.
    --- @param tbl table - The table to find the index of the last element in.
    --- @param fn function - The predicate function to satisfy.
    --- @return number|nil - The index of the last element that satisfies the predicate function, or nil if no element satisfies the predicate.
    --- @example
    --- ```lua
    --- table.findLastIndex({1, 2, 3, 4, 5}, function(i, v) return v > 3 end)
    --- -- 4
    --- ```
    function self.findLast(tbl, fn)
      ___.valid.indexed(tbl, 1, false)
      ___.valid.type(fn, "function", 2, false)

      for i = #tbl, 1, -1 do
        if fn(i, tbl[i]) then
          return i
        end
      end
      return nil
    end

    --- Flattens a table of tables into a single table.
    --- @param tbl table - The table to flatten.
    --- @return table - A new table containing the flattened table.
    --- @example
    --- ```lua
    --- table.flatten({1, {2, {3, {4}}, 5}})
    --- -- {1, 2, 3, 4, 5}
    --- ```
    function self.flatten(tbl)
      ___.valid.indexed(tbl, 1, false)

      local result = {}
      for _, v in ipairs(tbl) do
        if type(v) == "table" then
          mod.concat(___, result, v)
        else
          table.insert(result, v)
        end
      end

      return result
    end

    --- Flattens a table of tables into a single table recursively.
    --- @param tbl table - The table to flatten recursively.
    --- @return table - A new table containing the flattened table.
    --- @example
    --- ```lua
    --- table.flatten_deep({1, {2, {3, {4}}, 5}})
    --- -- {1, 2, 3, 4, 5}
    --- ```
    function self.flattenDeep(tbl)
      ___.valid.indexed(tbl, 1, false)

      local result = {}
      for _, v in ipairs(tbl) do
        if type(v) == "table" then
          mod.concat(___, result, mod.flatten_deep(___, v))
        else
          table.insert(result, v)
        end
      end

      return result
    end

    --- Returns a new table with the last element removed.
    --- @param tbl table - The table to remove the last element from.
    --- @return table - A new table with the last element removed.
    --- @example
    --- ```lua
    --- table.initial({1, 2, 3, 4, 5})
    --- -- {1, 2, 3, 4}
    --- ```
    function self.initial(tbl)
      ___.valid.indexed(tbl, 1, false)
      return self.slice(___, tbl, 1, #tbl - 1)
    end

    --- Returns a table with all of the specified values removed. This operation
    --- is destructive and modifies the original table, consequently, it is not
    --- necessary to capture the return value.
    --- @param tbl table - The table to remove the values from.
    --- @param ... any - The values to remove from the table.
    --- @return table - A table with the specified values removed.
    --- @example
    --- ```lua
    --- table.pull({ 1, 5, 2, 4, 5, 2, 3, 4, 5, 1 }, 2, 5)
    --- -- { 1, 4, 3, 4, 1 }
    --- ```
    function self.pull(tbl, ...)
      ___.valid.indexed(tbl, 1, false)

      local args = { ... }
      if #args == 0 then return tbl end

      local removeSet = {}
      for _, value in ipairs(args) do
        removeSet[value] = true
      end

      for i = #tbl, 1, -1 do
        if removeSet[tbl[i]] then
          table.remove(tbl, i)
        end
      end

      return tbl
    end

    --- Reverses the order of an indexed table. This operation is destructive and
    --- modifies the original table, consequently, it is not necessary to capture
    --- the return value.
    --- @param tbl table - The table to reverse.
    --- @return table - The reversed table.
    --- @example
    --- ```lua
    --- table.reverse({1, 2, 3, 4, 5})
    --- -- {5, 4, 3, 2, 1}
    --- ```
    function self.reverse(tbl)
      ___.valid.indexed(tbl, 1, false)

      local len, midpoint = #tbl, math.floor(#tbl / 2)
      for i = 1, midpoint do
        tbl[i], tbl[len - i + 1] = tbl[len - i + 1], tbl[i]
      end
      return tbl
    end

    --- Returns a new table with duplicate values removed. This operation is
    --- destructive and modifies the original table, consequently, it is not
    --- necessary to capture the return value. The first instance of each value
    --- is retained.
    --- @param tbl table - The table to remove duplicates from.
    --- @return table - A new table with duplicates removed.
    --- @example
    --- ```lua
    --- table.uniq({1, 2, 3, 4, 5, 1, 2, 3})
    --- -- {1, 2, 3, 4, 5}
    --- ```
    function self.uniq(tbl)
      ___.valid.indexed(tbl, 1, false)

      local seen = {}
      local writeIndex = 1

      for readIndex = 1, #tbl do
        local value = tbl[readIndex]
        if not seen[value] then
          seen[value] = true
          tbl[writeIndex] = value
          writeIndex = writeIndex + 1
        end
      end

      -- Remove excess elements beyond writeIndex
      for i = #tbl, writeIndex, -1 do
        tbl[i] = nil
      end

      return tbl
    end

    --- Unzips a table of tables into a table of tables.
    --- @param tbl table - The table to unzip.
    --- @return table - A table of tables.
    --- @example
    --- ```lua
    --- table.unzip({{1, 2}, {3, 4}, {5, 6}})
    --- -- {{1, 3, 5}, {2, 4, 6}}
    --- ```
    function self.unzip(tbl)
      ___.valid.indexed(tbl, 1, false)

      local size_of_table = #tbl
      -- Ensure that all sub-tables are of the same length
      local size_of_elements = #tbl[1]
      for _, t in ipairs(tbl) do ___.valid.test(size_of_elements == #t, t, 1, false) end

      local num_new_sub_tables = size_of_elements -- yes, this is redundant, but it's more readable
      local new_sub_table_size = size_of_table -- this is the size of the sub-tables
      local result = {}

      for i = 1, num_new_sub_tables do
        result[i] = {}
      end

      for _, source_table in ipairs(tbl) do
        for i, value in ipairs(source_table) do
          table.insert(result[i], value)
        end
      end

      return result
    end

    --- Creates a new table with weak references. Valid options are "v" for
    --- weak values, "k" for weak keys, and "kv" or "vk" for weak keys and
    --- values.
    --- @param opt string - The reference type.
    --- @return table - A new table with weak references.
    --- @example
    --- ```lua
    --- table.new_weak("v")
    --- -- A table with weak value references
    --- ```
    function self.newWeak(opt)
      ___.valid.test(rex.match(opt, "^(k?v?|v?k?)$"), opt, 1, true)

      opt = opt or "v"

      return setmetatable({}, { __mode = opt })
    end

    --- Checks if a table has weak references.
    --- @param tbl table - The table to check.
    --- @return boolean - Whether the table has weak references.
    --- @example
    --- ```lua
    --- table.weak(table.new_weak("v"))
    --- -- true
    --- ```
    function self.weak(tbl)
      ___.valid.type(tbl, "table", 1, false)
      return getmetatable(tbl) and getmetatable(tbl).__mode ~= nil
    end

    --- Zips multiple tables together. The tables must all be of the same length.
    --- @param ... table - The tables to zip together.
    --- @return table - A new table containing the zipped tables.
    --- @example
    --- ```lua
    --- table.zip({1, 2, 3}, {4, 5, 6}, {7, 8, 9})
    --- -- {{1, 4, 7}, {2, 5, 8}, {3, 6, 9}}
    --- ```
    function self.zip(...)
      local tbls = { ... }
      local results = {}

      local size = #tbls[1]
      for _, t in ipairs(tbls) do ___.valid:test(size == #t, t, 1, false) end

      for i = 1, size do
        results[i] = {}
        for _, t in ipairs(tbls) do
          table.insert(results[i], t[i])
        end
      end
      return results
    end

    --- Checks if a table includes a value.
    --- @param tbl table - The table to check.
    --- @param value any - The value to check for.
    --- @return boolean - Whether the table includes the value.
    --- @example
    --- ```lua
    --- table.includes({1, 2, 3}, 2)
    --- -- true
    --- ```
    function self.includes(tbl, value)
      ___.valid.indexed(tbl, 1, false)
      ___.valid.type(value, "any", 2, false)
      return table.index_of(tbl, value) ~= nil
    end

    local function collect_tables(tbl, inherited)
      -- Check if the table is a valid object with a metatable and an __index field
      ___.valid.object(tbl, 1, false)
      ___.valid.type(inherited, "boolean", 2, true)

      -- Set-like table to track visited tables
      local visited = {}
      local tables = {}

      local function add_table(t)
        if not visited[t] then
          table.insert(tables, t)
          visited[t] = true
        end
      end

      -- Start by adding the main table
      add_table(tbl)

      if inherited then
        local mt = getmetatable(tbl)
        while mt and mt.__index do
          local inheritedTbl = mt.__index
          if type(inheritedTbl) == "table" then
            add_table(inheritedTbl)
          end
          mt = getmetatable(inheritedTbl)
        end
      end

      return tables
    end

    --- Returns a table of keys for a given table that satisfy a test function.
    --- @param tbl table - The table to get the keys from.
    --- @param test function - The test function to satisfy.
    --- @return table - A table of the keys that satisfy the test function.
    --- @example
    --- ```lua
    --- table.get_types({a = 1, b = 2, c = 3}, function(tbl, k) return tbl[k] > 2 end)
    --- -- {"c"}
    --- ```
    local function get_types(tbl, test)
      ___.valid.type(tbl, "table", 1, false)
      ___.valid.type(test, "function", 2, false)

      local keys = table.keys(tbl)
      keys = table.n_filter(keys, function(k) return test(tbl, k) end) or {}
      return keys
    end

    local function assemble_results(tables, test)
      local result = {}
      for _, t in ipairs(tables) do
        local keys = get_types(t, test) or {}
        for _, k in ipairs(keys) do
          if not mod.includes(___, result, k) then
            table.insert(result, k)
          end
        end
      end
      return result
    end

    --- Returns a table of methods for a given table. A method is a function that
    --- uses the `:` accessor syntax and the value of self is implicitly passed
    --- to function.
    ---
    --- @param tbl table - The table to get the methods from.
    --- @param inherited boolean - Whether to include inherited methods.
    --- @return table - A table of the string names of the methods.
    --- @example
    --- ```lua
    --- table.methods(object, true)
    --- -- {"method1", "method2"}
    --- ```
    function self.functions(tbl, inherited)
      ___.valid.object(tbl, 1, false)
      ___.valid.type(inherited, "boolean", 2, true)

      local tables = collect_tables(tbl, inherited) or {}
      local test = function(t, k) return type(t[k]) == "function" end

      return assemble_results(tables, test)
    end
    -- Alias for functions
    self.methods = self.functions

    function self.properties(tbl, inherited)
      ___.valid.object(tbl, 1, false)
      ___.valid.type(inherited, "boolean", 2, true)

      local tables = collect_tables(tbl, inherited) or {}
      local test = function(t, k) return type(t[k]) ~= "function" end

      return assemble_results(tables, test)
    end

    --- Checks if a table is an object.
    --- @param tbl table - The table to check.
    --- @return boolean - Whether the table is an object.
    --- @example
    --- ```lua
    --- local object1 = {1,2,3}
    --- local object2 = {}
    --- setmetatable(object2, { __index = object1 })
    ---
    --- table.object(object1)
    --- -- false
    --- table.object(object2)
    --- -- true
    --- ```
    function self.is_object(tbl)
      ___.valid.type(tbl, "table", 1, false)
      return tbl.object == true
    end

    --- Adds two associative tables together, merging the second table into the
    --- first. Keys in the second table that already exist in the first table
    --- will overwrite the value in the first table.
    ---
    --- This operation is destructive and modifies the original table,
    --- consequently, it is not necessary to capture the return value.
    ---
    --- @param tbl table - The table to add the value to.
    --- @param value table - The table to add to the first table.
    --- @return table - The first table with the second table added.
    --- @example
    --- ```lua
    --- table.add({a = 1, b = 2}, {c = 3, d = 4})
    --- -- {a = 1, b = 2, c = 3, d = 4}
    ---
    --- table.add({a = 1, b = 2}, {c = 3, d = 4}, 1)
    --- -- {a = 1, c = 3, d = 4, b = 2}
    --- ```
    function self.add(tbl, value)
      ___.valid.associative(tbl, 1, false)
      ___.valid.associative(value, 2, false)

      for k, v in pairs(value) do
        tbl[k] = v
      end

      return tbl
    end

    --- Merge a second indexed table into a first indexed table. At a given
    --- index, the second table is inserted into the first table. Effectively,
    --- the second table is expanded and then inserted into the first table.
    ---
    --- If an index is provided, the second table will be inserted at that index.
    --- Otherwise, the second table will be inserted at the end of the first
    --- table.
    ---
    --- This operation is destructive and modifies the original table,
    --- consequently, it is not necessary to capture the return value.
    ---
    --- @param tbl1 table - The table to add the value to.
    --- @param tbl2 table - The table to add to the indexed table.
    --- @param index number - The index to add the value to.
    --- @return table - The indexed table with the value added.
    --- @example
    --- ```lua
    --- table.n_add({"a", "b", "c"}, {"d", "e", "f"})
    --- -- {"a", "b", "c", "d", "e", "f"}
    ---
    --- table.n_add({{a = 1}, {b = 2}, {c = 3}}, {{d = 4}, {e = 5}, {f = 6}}, 2)
    --- -- {{a = 1}, {b = 2}, {d = 4}, {e = 5}, {f = 6}, {c = 3}}
    --- ```
    function self.n_add(tbl1, tbl2, index)
      ___.valid.indexed(tbl1, 1, false)
      ___.valid.indexed(tbl2, 2, false)
      ___.valid.range(index, 1, #tbl1 + 1, 3, true)

      -- We are not adding +1 to the end index because we will be doing +1
      -- in the loop below
      index = index or #tbl1 + 1

      for i = 1, #tbl2 do
        table.insert(tbl1, index + i - 1, tbl2[i])
      end

      return tbl1
    end

    --- Walks over a table, returning an iterator.
    --- @param tbl table - The table to walk over.
    --- @return function - The iterator function.
    --- @example
    --- ```lua
    --- for i, v in table.walk({1, 2, 3, 4, 5}) do
    ---   print(i, v) -- prints 1=1, 2=2, 3=3, 4=4, 5=5
    --- end
    --- ```
    function self.walk(tbl)
      ___.valid.indexed(tbl, 1, false)

      local i = 0
      return function()
        i = i + 1
        if tbl[i] then return i, tbl[i] end
      end
    end

    --- Checks if a caller inherits from a base class.
    --- @param caller table - The caller to check.
    --- @param base_class table - The base class to check against.
    --- @return boolean - Whether the caller inherits from the base class.
    --- @example
    --- ```lua
    --- table.inherits(object, base_class)
    --- -- true
    --- ```
    function self.inherits(caller, base_class)
      -- ___.valid.object(caller, 1, false)
      -- ___.valid.object(base_class, 2, false)

      local current_instance = caller
      while current_instance do
        if current_instance == base_class then
          return true
        end
        current_instance = current_instance.parent
      end
      return false
    end

    --- Protects a function so that it can only be called by inheriting classes.
    --- @param object table - The object to protect the function on.
    --- @param function_name string - The name of the function to protect.
    --- @example
    --- ```lua
    --- table.protect_function(object, "function_name")
    --- ```
    function self.protect_function(object, function_name)
      -- ___.valid.object(object, 1, false)
      ___.valid.type(function_name, "string", 2, false)

      local original_function = object[function_name]
      ___.valid.type(original_function, "function", 2, false)

      object[function_name] = function(caller, ...)
        if self.inherits(caller, object) then
          return original_function(caller, ...)
        end
        error("Access denied: " .. function_name .. " is protected and can " ..
          "only be called by inheriting classes.")
      end
    end

    --- Protects a variable so that it can only be accessed by inheriting
    --- classes.
    --- @param object table - The object to protect the variable on.
    --- @param var_name string - The name of the variable to protect.
    --- @example
    --- ```lua
    --- table.protect_variable(object, "var_name")
    --- ```
    function self.protect_variable(object, var_name)
      -- ___.valid.object(object, 1, false)
      ___.valid.type(var_name, "string", 2, false)
      ___.valid.type(object[var_name], "any", 2, false)

      local base_class = getmetatable(object)

      setmetatable(object, {
        __index = function(tbl, key)
          if key == var_name and not self.inherits(tbl, base_class) then
            error("Access denied: Variable '" ..
            var_name .. "' is protected and can only be accessed by inheriting classes.")
          end
          return rawget(tbl, key)
        end,
        __newindex = function(tbl, key, value)
          if key == var_name and not self.inherits(tbl, base_class) then
            error("Access denied: Variable '" ..
            var_name .. "' is protected and can only be modified by inheriting classes.")
          end
          rawset(tbl, key, value)
        end,
      })
    end
  end
})
