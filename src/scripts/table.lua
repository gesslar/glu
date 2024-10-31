---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "table"
function mod.new(parent)
  local instance = {
    parent = parent,
    ___ = (function(p)
      while p.parent do p = p.parent end
      return p
    end)(parent)
  }

  --- Casts a value to an indexed table if it is not already one.
  ---
  --- @param ...any - The value to cast.
  --- @return table - A new indexed table with the value or the value itself if it is already indexed.
  ---
  --- @example
  --- ```lua
  --- table:n_cast(1)
  --- -- {1}
  --- ```
  function instance:n_cast(...)
    if type(...) == "table" and self:indexed(...) then
      return ...
    end

    return { ... }
  end

  instance.assure_indexed = instance.n_cast

  --- Takes a table and a function and returns a new table with the function
  --- applied to each element of the original table.
  ---
  --- @param t table - The table to map over.
  --- @param fn function - The function to apply to each element of the table.
  --- @param ... any - Additional arguments to pass to the function.
  --- @return table - A new table with the function applied to each element.
  --- @example
  --- ```lua
  --- table:map({1, 2, 3}, function(k, v) return v * 2 end)
  --- -- {2, 4, 6}
  --- ```
  function instance:map(t, fn, ...)
    self.___.valid:type(t, "table", 1, false)
    self.___.valid:type(fn, "function", 2, false)

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
  --- table:values({a = 1, b = 2, c = 3})
  --- -- {1, 2, 3}
  --- ```
  function instance:values(t)
    self.___.valid:type(t, "table", 1, false)

    local result = {}
    for _, v in pairs(t) do
      result[#result + 1] = v
    end
    return result
  end

  --- Checks if all elements in the table are of the same type.
  --- @param t table - The table to check.
  --- @param typ string - The type to check for.
  --- @return boolean - True if all elements are of the same type, false otherwise.
  --- @example
  --- ```lua
  --- table:n_uniform({1, 2, 3}, "number")
  --- -- true
  --- ```
  function instance:n_uniform(t, typ)
    self.___.valid:type(t, "table", 1, false)
    self.___.valid:not_empty(t, 1, false)
    self.___.valid:indexed(t, 1, false)
    self.___.valid:type(typ, "string", 2, false)

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
  --- table:n_distinct({1, 2, 2, 3, 4, 4, 5})
  --- -- {1, 2, 3, 4, 5}
  --- ```
  function instance:n_distinct(t)
    self.___.valid:indexed(t, 1, false)

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
  --- table:pop({1, 2, 3})
  --- -- 3
  --- ```
  function instance:pop(t)
    self.___.valid:type(t, "table", 1, false)
    self.___.valid:indexed(t, 1, false)
    return table.remove(t, #t)
  end

  --- Adds an element to the end of a table and returns the new length of the table.
  --- @param t table - The table to push the element to.
  --- @param v any - The element to push to the table.
  --- @return number - The new length of the table.
  --- @example
  --- ```lua
  --- table:push({1, 2, 3}, 4)
  --- -- 4
  --- ```
  function instance:push(t, v)
    self.___.valid:type(t, "table", 1, false)
    self.___.valid:type(v, "any", 2, false)
    self.___.valid:indexed(t, 1, false)
    table.insert(t, v)

    return #t
  end

  --- Adds an element to the beginning of a table and returns the new length of the table.
  --- @param t table - The table to unshift the element to.
  --- @param v any - The element to unshift to the table.
  --- @return number - The new length of the table.
  --- @example
  --- ```lua
  --- table:unshift({2, 3, 4}, 1)
  --- -- 4
  --- ```
  function instance:unshift(t, v)
    self.___.valid:type(t, "table", 1, false)
    self.___.valid:type(v, "any", 2, false)
    self.___.valid:indexed(t, 1, false)
    table.insert(t, 1, v)

    return #t
  end

  --- Removes and returns the first element of a table.
  --- @param t table - The table to shift the first element from.
  --- @return any - The first element of the table.
  --- @example
  --- ```lua
  --- table:shift({1, 2, 3})
  --- -- 1
  --- ```
  function instance:shift(t)
    self.___.valid:type(t, "table", 1, false)
    self.___.valid:indexed(t, 1, false)
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
  --- table:allocate({"a", "b", "c"}, "x")
  --- -- {a = "x", b = "x", c = "x"}
  --- ```
  --- ```lua
  --- table:allocate({"a","b","c"}, {1, 2, 3})
  --- -- {a = 1, b = 2, c = 3}
  --- ```
  --- ```lua
  --- table:allocate({ "a", "b", "c" }, function(k, v)
  ---   return string.byte(v)
  --- end)
  --- -- {a = 97, b = 98, c = 99}
  --- ```
  function instance:allocate(source, spec)
    local spec_type = type(spec)
    self.___.valid:type(source, "table", 1, false)
    self.___.valid:not_empty(source, 1, false)
    self.___.valid:indexed(source, 1, false)
    if spec_type == instance.___.TYPE.TABLE then
      self.___.valid:indexed(spec, 2, false)
      assert(#source == #spec, "Expected source and spec to have the same number of elements")
    elseif spec_type == instance.___.TYPE.FUNCTION then
      self.___.valid:type(spec, "function", 2, false)
    end

    local result = {}

    if spec_type == instance.___.TYPE.TABLE then
      for i = 1, #spec do
        result[source[i]] = spec[i]
      end
    elseif spec_type == instance.___.TYPE.FUNCTION then
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
  --- table:indexed({1, 2, 3})
  --- -- true
  --- ```
  function instance:indexed(t)
    self.___.valid:type(t, "table", 1, false)

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
  --- table:associative({a = 1, b = 2, c = 3})
  --- -- true
  --- ```
  function instance:associative(t)
    self.___.valid:type(t, "table", 1, false)

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
  --- table:reduce({1, 2, 3}, function(acc, v) return acc + v end, 0)
  --- -- 6
  --- ```
  function instance:n_reduce(t, fn, initial)
    self.___.valid:indexed(t, 1, false)
    self.___.valid:type(fn, "function", 2, false)
    self.___.valid:type(initial, "any", 3, false)

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
  --- table:slice({1, 2, 3, 4, 5}, 2, 4)
  --- -- {2, 3, 4}
  --- ```
  --- ```lua
  --- table:slice({1, 2, 3, 4, 5}, 2)
  --- -- {2, 3, 4, 5}
  --- ```
  function instance:slice(t, start, stop)
    self.___.valid:indexed(t, 1, false)
    self.___.valid:type(start, "number", 2, false)
    self.___.valid:type(stop, "number", 3, true)
    self.___.valid:test(start >= 1, 2, false)
    self.___.valid:test(table.size(t) >= start, 2, false)
    self.___.valid:test(stop and stop >= start, 3, true)

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
  --- table:remove({1, 2, 3, 4, 5}, 2, 4)
  --- -- {1, 5}
  --- -- {2, 3, 4}
  --- ```
  --- ```lua
  --- table:remove({1, 2, 3, 4, 5}, 2)
  --- -- {1, 3, 4, 5}
  --- -- {2}
  --- ```
  function instance:remove(t, start, stop)
    self.___.valid:indexed(t, 1, false)
    self.___.valid:type(start, "number", 2, false)
    self.___.valid:type(stop, "number", 3, true)
    self.___.valid:test(start >= 1, 2, false)
    self.___.valid:test(table.size(t) >= start, 2, false)
    self.___.valid:test(stop and stop >= start, 3, true)

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
  --- table:chunk({1, 2, 3, 4, 5}, 2)
  --- -- {{1, 2}, {3, 4}, {5}}
  --- ```
  function instance:chunk(t, size)
    self.___.valid:indexed(t, 1, false)
    self.___.valid:type(size, "number", 2, false)

    local result = {}
    for i = 1, #t, size do
      result[#result + 1] = self:slice(t, i, i + size - 1)
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
  --- table:concat({1}, 2, {3}, {{4}})
  --- -- {1, 2, 3, {4}}
  --- ```
  function instance:concat(tbl, ...)
    self.___.valid:indexed(tbl, 1, false)

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
  --- table:drop({1, 2, 3, 4, 5}, 3)
  --- -- {4, 5}
  --- ```
  function instance:drop(tbl, n)
    self.___.valid:indexed(tbl, 1, false)
    self.___.valid:type(n, "number", 2, false)
    self.___.valid:test(n >= 1, 2, false)
    return self:slice(tbl, n + 1)
  end

  --- Returns a new table with the last n elements removed.
  --- @param tbl table - The table to drop the last n elements from.
  --- @param n number - The number of elements to drop from the table.
  --- @return table - A new table with the last n elements removed.
  --- @example
  --- ```lua
  --- table:dropRight({1, 2, 3, 4, 5}, 3)
  --- -- {1, 2}
  --- ```
  function instance:dropRight(tbl, n)
    self.___.valid:indexed(tbl, 1, false)
    self.___.valid:type(n, "number", 2, false)
    self.___.valid:test(n >= 1, 2, false)
    return self:slice(tbl, 1, #tbl - n)
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
  --- table:fill({1, 2, 3, 4, 5}, "x")
  --- -- {"x", "x", "x", "x", "x"}
  --- ```
  function instance:fill(tbl, value, start, stop)
    self.___.valid:indexed(tbl, 1, false)
    self.___.valid:type(value, "any", 2, false)
    self.___.valid:type(start, "number", 3, true)
    self.___.valid:type(stop, "number", 4, true)
    self.___.valid:test(start and start >= 1, value, 3, true)
    self.___.valid:test(stop and stop >= start, value, 4, true)

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
  --- table:findIndex({1, 2, 3, 4, 5}, function(i, v) return v > 3 end)
  --- -- 4
  --- ```
  function instance:findIndex(tbl, fn)
    self.___.valid:indexed(tbl, 1, false)
    self.___.valid:type(fn, "function", 2, false)

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
  --- table:findLastIndex({1, 2, 3, 4, 5}, function(i, v) return v > 3 end)
  --- -- 4
  --- ```
  function instance:findLastIndex(tbl, fn)
    self.___.valid:indexed(tbl, 1, false)
    self.___.valid:type(fn, "function", 2, false)

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
  --- table:flatten({1, {2, {3, {4}}, 5}})
  --- -- {1, 2, 3, 4, 5}
  --- ```
  function instance:flatten(tbl)
    self.___.valid:indexed(tbl, 1, false)

    local result = {}
    for _, v in ipairs(tbl) do
      if type(v) == "table" then
        self:concat(result, v)
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
  --- table:flattenDeep({1, {2, {3, {4}}, 5}})
  --- -- {1, 2, 3, 4, 5}
  --- ```
  function instance:flattenDeep(tbl)
    self.___.valid:indexed(tbl, 1, false)

    local result = {}
    for _, v in ipairs(tbl) do
      if type(v) == "table" then
        self:concat(result, self:flattenDeep(v))
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
  --- table:initial({1, 2, 3, 4, 5})
  --- -- {1, 2, 3, 4}
  --- ```
  function instance:initial(tbl)
    self.___.valid:indexed(tbl, 1, false)
    return self:slice(tbl, 1, #tbl - 1)
  end

  --- Returns a table with all of the specified values removed. This operation
  --- is destructive and modifies the original table, consequently, it is not
  --- necessary to capture the return value.
  --- @param tbl table - The table to remove the values from.
  --- @param ... any - The values to remove from the table.
  --- @return table - A table with the specified values removed.
  --- @example
  --- ```lua
  --- table:pull({ 1, 5, 2, 4, 5, 2, 3, 4, 5, 1 }, 2, 5)
  --- -- { 1, 4, 3, 4, 1 }
  --- ```
  function instance:pull(tbl, ...)
    self.___.valid:indexed(tbl, 1, false)

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
  --- table:reverse({1, 2, 3, 4, 5})
  --- -- {5, 4, 3, 2, 1}
  --- ```
  function instance:reverse(tbl)
    self.___.valid:indexed(tbl, 1, false)

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
  --- table:uniq({1, 2, 3, 4, 5, 1, 2, 3})
  --- -- {1, 2, 3, 4, 5}
  --- ```
  function instance:uniq(tbl)
    self.___.valid:indexed(tbl, 1, false)

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

  function instance:unzip(tbl)
    self.___.valid:indexed(tbl, 1, false)

    local size_of_table = #tbl
    -- Ensure that all sub-tables are of the same length
    local size_of_elements = #tbl[1]
    for _, t in ipairs(tbl) do self.___.valid:test(size_of_elements == #t, t, 1, false) end

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
  --- table:new_weak("v")
  --- -- A table with weak value references
  --- ```
  function instance:new_weak(opt)
    self.___.valid:test(rex.match(opt, "^(k?v?|v?k?)$"), opt, 1, true)

    opt = opt or "v"

    return setmetatable({}, { __mode = opt })
  end

  --- Checks if a table has weak references.
  --- @param tbl table - The table to check.
  --- @return boolean - Whether the table has weak references.
  --- @example
  --- ```lua
  --- table:weak(table:new_weak("v"))
  --- -- true
  --- ```
  function instance:weak(tbl)
    self.___.valid:type(tbl, "table", 1, false)
    return getmetatable(tbl) and getmetatable(tbl).__mode ~= nil
  end

  --- Zips multiple tables together. The tables must all be of the same length.
  --- @param ... table - The tables to zip together.
  --- @return table - A new table containing the zipped tables.
  --- @example
  --- ```lua
  --- table:zip({1, 2, 3}, {4, 5, 6}, {7, 8, 9})
  --- -- {{1, 4, 7}, {2, 5, 8}, {3, 6, 9}}
  --- ```
  function instance:zip(...)
    local tbls = { ... }
    local results = {}

    local size = #tbls[1]
    for _, t in ipairs(tbls) do self.___.valid:test(size == #t, t, 1, false) end

    for i = 1, size do
      results[i] = {}
      for _, t in ipairs(tbls) do
        table.insert(results[i], t[i])
      end
    end
    return results
  end

  function instance:includes(tbl, value)
    self.___.valid:indexed(tbl, 1, false)
    self.___.valid:type(value, "any", 2, false)
    return table.index_of(tbl, value) ~= nil
  end

  local function collect_tables(self, tbl, inherited)
    -- Check if the table is a valid object with a metatable and an __index field
    self.___.valid:object(tbl, 1, false)
    self.___.valid:type(inherited, "boolean", 2, true)

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

  local function get_types(self, tbl, test)
    self.___.valid:type(tbl, "table", 1, false)
    self.___.valid:type(test, "function", 2, false)

    local keys = table.keys(tbl)
    keys = table.n_filter(keys, function(k) return test(tbl, k) end) or {}
    return keys
  end

  local function assemble_results(self, tables, test)
    local result = {}
    for _, t in ipairs(tables) do
      local keys = get_types(self, t, test) or {}
      for _, k in ipairs(keys) do
        if not self:includes(result, k) then
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
  --- table:methods(object, true)
  --- -- {"method1", "method2"}
  --- ```
  function instance:functions(tbl, inherited)
    self.___.valid:object(tbl, 1, false)
    self.___.valid:type(inherited, "boolean", 2, true)

    local tables = collect_tables(self, tbl, inherited) or {}
    local test = function(t, k) return type(t[k]) == "function" end

    return assemble_results(self, tables, test)
  end
  -- Alias for functions
  instance.methods = instance.functions

  function instance:properties(tbl, inherited)
    self.___.valid:object(tbl, 1, false)
    self.___.valid:type(inherited, "boolean", 2, true)

    local tables = collect_tables(self, tbl, inherited) or {}
    local test = function(t, k) return type(t[k]) ~= "function" end

    return assemble_results(self, tables, test)
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
  --- table:object(object1)
  --- -- false
  --- table:object(object2)
  --- -- true
  --- ```
  function instance:object(tbl)
    self.___.valid:type(tbl, "table", 1, false)
    local mt = getmetatable(tbl)
    return mt and mt.__index ~= nil
  end

  instance.___.valid = instance.___.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
