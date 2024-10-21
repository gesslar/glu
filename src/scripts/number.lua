---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "number"
function mod.new(parent)
  local instance = { parent = parent }

  --- number:round(num, digits)
  --- Rounds a number to a specified number of decimal places.
  --- @type function
  --- @param num number - The number to round.
  --- @param digits number - The number of digits to round to. (Optional. Default is 0.)
  --- @return number - The rounded number.
  function instance:round(num, digits)
    self.parent.valid:type(num, "number", 1, false)
    self.parent.valid:type(digits, "number", 2, true)

    digits = digits or 0

    local mult = 10 ^ digits
    return math.floor(num * mult + 0.5) / mult
  end

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
