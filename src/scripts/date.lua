---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "date"
function mod.new(parent)
  local instance = {
    parent = parent,
    ___ = (function(p)
      while p.parent do p = p.parent end
      return p
    end)(parent)
  }

  --- Converts the number of seconds to a human-readable strings of hours,
  --- minutes, and seconds.
  ---
  --- If the optional argument is provided, it will be used as the format
  --- string as 5m 50s
  ---
  --- Ripped off from https://github.com/Mudlet/Mudlet/blob/development/src/mudlet-lua/lua/Other.lua
  --- But doesn't force colours into the output.
  --- @example
  --- ```lua
  --- date:shms(350)
  --- -- "00"
  --- -- "05"
  --- -- "50"
  --- ```
  ---
  --- ```lua
  --- date:shms(350, true)
  --- -- "5m 50s"
  --- ```
  --- @param seconds number - The number of seconds to convert.
  --- @param as_string boolean|nil - Whether to return a string instead of three separate values. (Optional. Default is false.)
  --- @return string,string,string|string - If `as_string` is false or not provided, returns hours, minutes, and seconds as strings, otherwise returns a single formatted string.
  function instance:shms(seconds, as_string)
    self.___.valid:type(seconds, "number", 1, false)
    self.___.valid:type(as_string, "boolean", 2, true)

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

  instance.___.valid = instance.___.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
