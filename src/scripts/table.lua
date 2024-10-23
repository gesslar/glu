---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "table"
function mod.new(parent)
  local instance = {
    parent = parent or {}
  }

  --- table.map(t, fn, ...)
  --- Takes a table and a function and returns a new table with the function
  --- applied to each element of the original table.
  --- @type function - Applies a function to each element of a table.
  --- @param t table - The table to map over.
  --- @param fn function - The function to apply to each element of the table.
  --- @param ... any - Additional arguments to pass to the function.
  --- @return table - A new table with the function applied to each element.
  function instance:map(t, fn, ...)
    self.parent.valid:type(t, "table", 1, false)
    self.parent.valid:type(fn, "function", 2, false)

    local result = {}
    for k, v in pairs(t) do
      result[k] = fn(k, v, ...)
    end
    return result
  end

  --- table.values(t)
  --- Takes a table and returns a new table with the values of the original table.
  --- @type function - Returns a table of values from a given table.
  --- @param t table - The table to get the values from.
  --- @return table - A new table with the values of the original table.
  function instance:values(t)
    self.parent.valid:type(t, "table", 1, false)

    local result = {}
    for _, v in pairs(t) do
      result[#result + 1] = v
    end
    return result
  end

  --- table.uniform_type(t, typ)
  --- Checks if all elements in the table are of the same type.
  --- @type function - Checks if all elements in a table are of the same type.
  --- @param t table - The table to check.
  --- @param typ string - The type to check for.
  --- @return boolean - True if all elements are of the same type, false otherwise.
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

  --- table.distinct(t)
  --- Takes a table and returns a new table with the distinct elements of the original table.
  --- @type function - Returns a table of distinct elements from a given table.
  --- @param t table - The table to get the distinct elements from.
  --- @return table - A new table with the distinct elements of the original table.
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

  --- table.pop(t)
  --- Removes and returns the last element of a table.
  --- @type function - Removes and returns the last element of a table.
  --- @param t table - The table to pop the last element from.
  --- @return any - The last element of the table.
  function instance:pop(t)
    self.parent.valid:type(t, "table", 1, false)

    return table.remove(t, #t)
  end

  --- table.push(t, v)
  --- Adds an element to the end of a table and returns the new length of the table.
  --- @type function - Adds an element to the end of a table and returns the new length of the table.
  --- @param t table - The table to push the element to.
  --- @param v any - The element to push to the table.
  --- @return number - The new length of the table.
  function instance:push(t, v)
    self.parent.valid:type(t, "table", 1, false)
    self.parent.valid:type(v, "any", 2, false)

    table.insert(t, v)

    return #t
  end

  --- table.unshift(t, v)
  --- Adds an element to the beginning of a table and returns the new length of the table.
  --- @type function - Adds an element to the beginning of a table and returns the new length of the table.
  --- @param t table - The table to unshift the element to.
  --- @param v any - The element to unshift to the table.
  --- @return number - The new length of the table.
  function instance:unshift(t, v)
    self.parent.valid:type(t, "table", 1, false)
    self.parent.valid:type(v, "any", 2, false)

    table.insert(t, 1, v)

    return #t
  end

  --- table.shift(t)
  --- Removes and returns the first element of a table.
  --- @type function - Removes and returns the first element of a table.
  --- @param t table - The table to shift the first element from.
  --- @return any - The first element of the table.
  function instance:shift(t)
    self.parent.valid:type(t, "table", 1, false)

    return table.remove(t, 1)
  end

  --- table.allocate(source, spec)
  --- Allocates a new table based on the source and spec.
  --- @type function - Allocates a new table based on the source and spec.
  --- @param source table - The source table to allocate from.
  --- @param spec any - The spec to allocate the new table with.
  --- @return table - A new table allocated from the source and spec.
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
        result[i] = spec(source[i])
      end
    else
      for i = 1, #source do
        result[i] = spec
      end
    end

    return result
  end

  --- table.is_indexed(t)
  --- Checks if a table is indexed (like an array).
  --- @type function - Checks if a table is indexed (like an array).
  --- @param t table - The table to check.
  --- @return boolean - True if the table is indexed, false otherwise.
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

  --- table.is_associative(t)
  --- Checks if a table is associative (has non-integer keys).
  --- @type function - Checks if a table is associative (has non-integer keys).
  --- @param t table - The table to check.
  --- @return boolean - True if the table is associative, false otherwise.
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
