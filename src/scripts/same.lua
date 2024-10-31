local script_name = "same"
local deps = { "valid" }

---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
function mod.new(parent)
  local instance = {
    parent = parent,
    ___ = (function(p)
      while p.parent do p = p.parent end
      return p
    end)(parent)
  }

  function instance:value_zero(value1, value2)
    -- If types are different, return false
    if type(value1) ~= type(value2) then
      return false
    end

    -- If type is 'number', handle special cases for NaN and zero
    if type(value1) == "number" then
      if value1 ~= value1 and value2 ~= value2 then -- Check if both x and y are NaN
        return true
      elseif value1 == 0 and value2 == 0 then
        -- Handle +0 and -0
        return true
      elseif value1 == value2 then
        return true
      else
        return false
      end
    end

    -- For non-number values, use a simple equality check
    return value1 == value2
  end

  function instance:value(value1, value2)
    -- If types are different, return false
    if type(value1) ~= type(value2) then
      return false
    end

    -- If type is 'number', handle special cases for NaN and zero
    if type(value1) == "number" then
      if value1 ~= value1 and value2 ~= value2 then  -- Check if both x and y are NaN
        return true
      elseif value1 == 0 and value2 == 0 then
        -- Handle +0 and -0 (they are considered different)
        return 1 / value1 == 1 / value2  -- +0 and -0 have different reciprocals
      elseif value1 == value2 then
        return true
      else
        return false
      end
    end

    -- For non-number values, use a simple equality check
    return value1 == value2
  end

  -- Lazy-load dependencies
  local f = function(_, k) return function(...) end end
  for _, d in ipairs(deps) do
    instance.___[d] = instance.___[d] or setmetatable({}, { __index = f })
  end
  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
