-- Define the class as a table
glu = glu or {}

-- Date module
glu.date = glu.date or {}

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
function glu.date.shms(seconds, as_string)
  glu.valid.type(seconds, "number", 1, false)
  glu.valid.type(as_string, "boolean", 2, true)

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

-- Timer module
glu.timer = glu.timer or {}

local multi_timers = {}
local function perform_multi_timer_function(self, name)
  local timer_function = multi_timers[name]
  if not timer_function then return end

  local defs = timer_function.def
  local def = defs[1]
  local ok, result = pcall(def.func, def.args)
  if not ok then
    glu.timer.kill_multi(name)
    return
  end

  table.remove(defs, 1)
  if #defs > 0 then
    local result2 = self:multi(name, defs)
  else
    multi_timers[name] = nil
  end
end

--- timer.multi(name, def)
--- Creates nested timers and returns
--- @type function - Creates nested timers and returns
--- @param name string - The name of the multi timer.
--- @param def table - The definition of the multi timer.
--- @param delay number - The delay between each timer.
--- @return boolean - True if the multi timer was created, errors out if not.
function glu.timer.multi(name, def, delay)
  glu.valid.type(name, "string", 1, false)
  glu.valid.type(def, "table", 2, false)
  glu.valid.not_empty(def, 2, false)
  glu.valid.type(delay, "number", 3, true)

  if delay then
    def = glu.table.map(def, function(_, element)
      element.delay = delay
      return element
    end)
  end

  local timer_id = tempTimer(def[1].delay, function()
    perform_multi_timer_function(glu, name)
  end)

  assert(timer_id, "Failed to create multi timer " .. name)

  local timer_function = {
    id = timer_id,
    def = def,
  }

  multi_timers[name] = timer_function

  return true
end

--- timer.kill_multi(name)
--- Kills a multi timer
--- @type function - Kills a multi timer
--- @param name string - The name of the multi timer.
--- @return boolean|nil - True if the multi timer was killed, nil if it doesn't exist.
function glu.timer.kill_multi(name)
  glu.valid.type(name, "string", 1, false)
  local timer_function = multi_timers[name]
  if not timer_function then return nil end

  multi_timers[name] = nil
  local id = timer_function.id

  return killTimer(id)
end
