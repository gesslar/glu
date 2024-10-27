---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "version"

function mod.new(parent)
  local instance = { parent = parent }

  -- Returns 1 if one is greater than two, -1 if one is less than two, and 0 if they are the same
  local function _compare(one, two)
    if one == two then
      return 0
    end

    if type(one) == "number" then
      return one < two and -1 or 1
    elseif type(one) == "string" then
      return one < two and -1 or 1
    end

    return one < two and -1 or 1
  end

  --- Compares two version strings. They can be a number, or a string. If a
  --- string, then it can be a string representation of a number or a semver
  --- string.
  ---
  --- @param version1 string|number - The first version string or number.
  --- @param version2 string|number - The second version string or number.
  --- @return number - 1 if version1 is greater than version2, -1 if version1 is less than version2, and 0 if they are the same.
  --- @example
  --- ```lua
  --- version:compare("1.0.0", "2.0.0")
  --- -- -1
  --- ```
  function instance:compare(version1, version2)
    -- The versions must be of the same type
    self.parent.valid:test(type(version1) == "string" or type(version1) == "number", 1, "Invalid value to argument 1. Expected a string or number.")
    self.parent.valid:test(type(version2) == "string" or type(version2) == "number", 2, "Invalid value to argument 2. Expected a string or number.")
    self.parent.valid:same_type(version1, version2)

    version1 = tostring(version1)
    version2 = tostring(version2)

    -- Split the versions into parts
    local version1_parts = version1:split("%.")
    local version2_parts = version2:split("%.")

    self.parent.valid:test(type(version1_parts) == "table", 1, "Invalid value to argument 1. Expected a string.")
    self.parent.valid:test(type(version2_parts) == "table", 2, "Invalid value to argument 2. Expected a string.")

    self.parent.valid:test(#version1_parts == #version2_parts, 1, "Invalid value to arguments. Expected 1 and 2 to have the same number of parts.")

    for i = 1, #version1_parts do
      local result = _compare(version1_parts[i], version2_parts[i])
      if result ~= 0 then
        return result
      end
    end

    return 0
  end

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
