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

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
