---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "date"
function mod.new(parent)
  local instance = { parent = parent }

  --- Converts the number of seconds to a human-readable strings of hours, minutes, and seconds.
  --- For example: 350 seconds is "05:50"
  --- If the optional argument is provided, it will be used as the format string
  --- as 5m 50s
  ---
  --- Ripped off from https://github.com/Mudlet/Mudlet/blob/development/src/mudlet-lua/lua/Other.lua
  --- But doesn't force colours into the output.
  ---@type function
  ---@param seconds number - The number of seconds to convert.
  ---@param as_string boolean|nil - Whether to return a string instead of three separate values. (Optional. Default is false.)
  ---@return string, string, string - If `as_string` is false or not provided, returns hours, minutes, and seconds as strings.
  ---@return string - If `as_string` is true, returns a single formatted string.
  ---@overload fun(seconds: number, as_string: boolean|nil): string
  function instance:shms(seconds, as_string)
    self.parent.valid:type(seconds, "number", 1, false)
    self.parent.valid:type(as_string, "boolean", 2, true)

    local s = seconds or 0
    -- Hours
    local hh = math.floor(math.fmod((s / (60 * 60)), 24))
    -- Minutes
    local mm = math.floor(math.fmod((s / 60), 60))
    -- Seconds
    local ss = math.fmod(s, 60)

    if as_string then
      local r = {}
      if hh ~= 0 then
        r[#r + 1] = hh .. "h"
      end
      if mm ~= 0 then
        r[#r + 1] = mm .. "m"
      end
      if ss ~= 0 then
        r[#r + 1] = ss .. "s"
      end

      return table.concat(r, " ") or "0s"
    else
      local result_hours = hh and string.format("%02d", hh) or "00"
      local result_minutes = mm and string.format("%02d", mm) or "00"
      local result_seconds = ss and string.format("%02d", ss) or "00"
      return result_hours, result_minutes, result_seconds
    end
  end

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
