---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "number"
function mod.new(parent)
  local instance = {
    parent = parent,
    ___ = (function(p)
      while p.parent do p = p.parent end
      return p
    end)(parent)
  }

  --- Rounds a number to a specified number of decimal places.
  ---
  --- @param num number - The number to round.
  --- @param digits number - The number of digits to round to. (Optional. Default is 0.)
  --- @return number - The rounded number.
  --- @example
  --- ```lua
  --- number:round(3.14159, 2)
  --- -- 3.14
  --- ```
  function instance:round(num, digits)
    self.___.valid:type(num, "number", 1, false)
    self.___.valid:type(digits, "number", 2, true)

    digits = digits or 0

    local mult = 10 ^ digits
    return math.floor(num * mult + 0.5) / mult
  end


  --- Clamps a number within a range.
  --- @param num number - The number to clamp.
  --- @param min number - The minimum allowed value.
  --- @param max number - The maximum allowed value.
  --- @return number - The clamped number.
  function instance:clamp(num, min, max)
    self.___.valid:type(num, "number", 1, false)
    self.___.valid:type(min, "number", 2, false)
    self.___.valid:type(max, "number", 3, false)

    return math.max(min, math.min(num, max))
  end

  --- Linearly interpolates between two numbers.
  --- @param a number - The starting value.
  --- @param b number - The ending value.
  --- @param t number - The interpolation factor (between 0 and 1).
  --- @return number - The interpolated value.
  function instance:lerp(a, b, t)
    self.___.valid:type(a, "number", 1, false)
    self.___.valid:type(b, "number", 2, false)
    self.___.valid:type(t, "number", 3, false)
    self.___.valid:test(t >= 0 and t <= 1, t, 3, false, "Interpolation factor should be between 0 and 1")

    return a + (b - a) * t
  end

  --- Maps a number from one range to another.
  --- @param value number - The input number.
  --- @param in_min number - The minimum of the input range.
  --- @param in_max number - The maximum of the input range.
  --- @param out_min number - The minimum of the output range.
  --- @param out_max number - The maximum of the output range.
  --- @return number - The mapped number.
  function instance:map(value, in_min, in_max, out_min, out_max)
    self.___.valid:type(value, "number", 1, false)
    self.___.valid:type(in_min, "number", 2, false)
    self.___.valid:type(in_max, "number", 3, false)
    self.___.valid:type(out_min, "number", 4, false)
    self.___.valid:type(out_max, "number", 5, false)

    return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
  end

  --- Returns the sign of a number.
  --- @param num number - The number to check.
  --- @return number - -1 if num is negative, 1 if positive, and 0 if zero.
  function instance:sign(num)
    self.___.valid:type(num, "number", 1, false)

    if num > 0 then
      return 1
    elseif num < 0 then
      return -1
    else
      return 0
    end
  end

  --- Checks if two numbers are approximately equal within a percentage tolerance.
  --- @param a number - The first number.
  --- @param b number - The second number.
  --- @param percent_tolerance number - The percentage allowed difference (default is 5%).
  --- @return boolean - True if the numbers are approximately equal, false otherwise.
  function instance:is_approximate(a, b, percent_tolerance)
    self.___.valid:type(a, "number", 1, false)
    self.___.valid:type(b, "number", 2, false)
    self.___.valid:type(percent_tolerance, "number", 3, true)

    percent_tolerance = percent_tolerance or 5 -- Default to 5%
    local tolerance = math.abs(a) * (percent_tolerance / 100)
    return math.abs(a - b) <= tolerance
  end

  --- Returns the minimum value in a list of numbers or a table.
  --- @param ... number|table[] - Either a list of numbers or a single table of numbers.
  --- @return number - The minimum value.
  function instance:min(...)
    local args = { ... }
    local values

    if #args == 1 and type(args[1]) == "table" then
      values = args[1]
    elseif #args > 1 then
      values = args
    else
      error("Invalid argument type: expected a table or multiple numbers")
    end

    -- now ensure all values are numbers
    self.___.valid:n_uniform(values, "number", 1, false)

    -- Calculate the minimum value
    local result = math.huge
    for _, num in ipairs(values) do
      result = math.min(result, num)
    end

    return result
  end

  --- Returns the maximum value in a list of numbers or a table.
  --- @param ... number|number[] - Either a list of numbers or a single table of numbers.
  --- @return number - The maximum value.
  function instance:max(...)
    local args = { ... }
    local values

    if #args == 1 and type(args[1]) == "table" then
      values = args[1]
    elseif #args > 1 then
      values = args
    else
      error("Invalid argument type: expected a table or multiple numbers")
    end

    -- now ensure all values are numbers
    self.___.valid:n_uniform(values, "number", 1, false)

    -- Calculate the minimum value
    local result = -math.huge
    for _, num in ipairs(values) do
      result = math.max(result, num)
    end

    return result
  end

  function instance:sum(...)
    local args = self.___.table:n_cast(...)
    self.___.valid:n_uniform(args, "number", 1, false)
    return self.___.table:n_reduce(args, function(acc, num) return acc + num end, 0)
  end

  instance.___.valid = instance.___.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
