local script_name = "same"
local class_name = script_name:title() .. "Class"
local deps = { "table", "valid" }

local mod = Glu.registerClass({
  class_name = class_name,
  script_name = script_name,
  dependencies = deps,
})

function mod.setup(___, self)
  function self.value_zero(value1, value2)
    ___.valid.type(value1, "any", 1, false)
    ___.valid.type(value2, "any", 2, false)

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

  function self.value(value1, value2)
    ___.valid.type(value1, "any", 1, false)
    ___.valid.type(value2, "any", 2, false)

    -- If types are different, return false
    if type(value1) ~= type(value2) then
      return false
    end

    -- If type is 'number', handle special cases for NaN and zero
    if type(value1) == "number" then
      if value1 ~= value1 and value2 ~= value2 then -- Check if both x and y are NaN
        return true
      elseif value1 == 0 and value2 == 0 then
        -- Handle +0 and -0 (they are considered different)
        return 1 / value1 == 1 / value2 -- +0 and -0 have different reciprocals
      elseif value1 == value2 then
        return true
      else
        return false
      end
    end

    -- For non-number values, use a simple equality check
    return value1 == value2
  end
end
