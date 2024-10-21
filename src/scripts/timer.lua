---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "timer"

function mod.new(parent)
  local instance = { parent = parent }

  local multi_timers = {}
  local function perform_multi_timer_function(self, name)
    local timer_function = multi_timers[name]
    if not timer_function then return end

    local defs = timer_function.def
    local def = defs[1]
    local ok, result = pcall(def.func, def.args)
    if not ok then
      instance:kill_multi(name)
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
  --- Creates nested timers and returns true if successful.
  --- @type function - Creates nested timers and returns true if successful.
  --- @param name string - The name of the multi timer.
  --- @param def table - The definition of the multi timer.
  --- @param delay number - The delay between each timer.
  --- @return boolean - True if the multi timer was created, errors out if not.
  --- @example glu.timer.multi("Greetings", {
  --- { func = function() echo("hi\n") end },
  --- { func = function() echo("there\n") end },
  --- { func = function() echo("you\n") end },
  --- { func = function() echo("amazing\n") end },
  --- { func = function() echo("developer\n") end },
  --- })
  function instance:multi(name, def, delay)
    self.parent.valid:type(name, "string", 1, false)
    self.parent.valid:type(def, "table", 2, false)
    self.parent.valid:not_empty(def, 2, false)
    self.parent.valid:type(delay, "number", 3, true)

    if delay then
      def = self.parent.table.map(def, function(_, element)
        element.delay = delay
        return element
      end)
    end

    local timer_id = tempTimer(def[1].delay, function()
      perform_multi_timer_function(self, name)
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
  --- @example glu.timer.kill_multi("Greetings")
  function instance:kill_multi(name)
    self.parent.valid:type(name, "string", 1, false)
    local timer_function = multi_timers[name]
    if not timer_function then return nil end

    multi_timers[name] = nil
    local id = timer_function.id

    return killTimer(id)
  end

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
