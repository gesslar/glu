---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "table"
function mod.new(parent)
  local instance = {
    parent = parent or {}
  }

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
    self.parent.valid:type(t, "table", 1, false)
    self.parent.valid:type(fn, "function", 2, false)

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
    self.parent.valid:type(t, "table", 1, false)

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
  --- table:uniform_type({1, 2, 3}, "number")
  --- -- true
  --- ```
  function instance:uniform_type(t, typ)
    self.parent.valid:type(t, "table", 1, false)
    self.parent.valid:type(typ, "string", 2, false)

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
  --- table:distinct({1, 2, 2, 3, 4, 4, 5})
  --- -- {1, 2, 3, 4, 5}
  --- ```
  function instance:distinct(t)
    self.parent.valid:type(t, "table", 1, false)

    local result = {}
    for _, v in ipairs(t) do
      if not table.index_of(result, v) then
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
    self.parent.valid:type(t, "table", 1, false)

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
    self.parent.valid:type(t, "table", 1, false)
    self.parent.valid:type(v, "any", 2, false)

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
    self.parent.valid:type(t, "table", 1, false)
    self.parent.valid:type(v, "any", 2, false)

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
    self.parent.valid:type(t, "table", 1, false)

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
    self.parent.valid:type(source, "table", 1, false)
    self.parent.valid:not_empty(source, 1, false)
    self.parent.valid:indexed_table(source, 1, false)
    if spec_type == instance.parent.TYPE.TABLE then
      self.parent.valid:indexed_table(spec, 2, false)
      assert(#source == #spec, "Expected source and spec to have the same number of elements")
    elseif spec_type == instance.parent.TYPE.FUNCTION then
      self.parent.valid:type(spec, "function", 2, false)
    end

    local result = {}

    if spec_type == instance.parent.TYPE.TABLE then
      for i = 1, #spec do
        result[source[i]] = spec[i]
      end
    elseif spec_type == instance.parent.TYPE.FUNCTION then
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
  --- table:is_indexed({1, 2, 3})
  --- -- true
  --- ```
  function instance:is_indexed(t)
    if type(t) ~= "table" then return false end
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
  --- table:is_associative({a = 1, b = 2, c = 3})
  --- -- true
  --- ```
  function instance:is_associative(t)
    if type(t) ~= "table" then return false end
    for k, _ in pairs(t) do
      if type(k) ~= "number" or k % 1 ~= 0 or k <= 0 then
          return true
      end
    end
    return false
  end

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
