---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "timer"

function mod.new(parent)
  local instance = { parent = parent }

  local multi_timers = {}
  local function perform_multi_timer_function(self, name)
    local timer_function = multi_timers[name]
    if not timer_function then
      return false
    end

    local defs = timer_function.def
    local def = defs[1]
    local ok, result = pcall(def.func, def.args)

    if not ok then
      return false
    end

    table.remove(defs, 1)
    if #defs > 0 then
      local result2 = self:multi(name, defs)
      if not result2 then
        return false
      end
    else
      multi_timers[name] = nil
    end

    return true
  end

  --- Creates nested timers and returns true if successful.
  --- @param name string - The name of the multi timer.
  --- @param def table - The definition of the multi timer.
  --- @param delay number - The delay between each timer.
  --- @return boolean - True if the multi timer was created, errors out if not.
  --- @example
  --- ```lua
  --- -- At intervals of 5 seconds, print "hi", "there", "you", "amazing", and
  --- -- "developer"
  --- timer.multi("Greetings", {
  ---   { func = function() echo("hi\n") end },
  ---   { func = function() echo("there\n") end },
  ---   { func = function() echo("you\n") end },
  ---   { func = function() echo("amazing\n") end },
  ---   { func = function() echo("developer\n") end },
  --- }, 5)
  --- ```
  ---
  --- ```lua
  --- -- After 1s, print "hi", after 3s, print "there", after 6s, print "you",
  --- -- after 10s, print "amazing", and after 15s, print "developer"
  --- timer.multi("Greetings", {
  ---   { delay = 1, func = function() echo("hi\n") end },
  ---   { delay = 2, func = function() echo("there\n") end },
  ---   { delay = 3, func = function() echo("you\n") end },
  ---   { delay = 4, func = function() echo("amazing\n") end },
  ---   { delay = 5, func = function() echo("developer\n") end },
  --- })
  --- ```
  function instance:multi(name, def, delay)
    self.parent.valid:type(name, "string", 1, false)
    self.parent.valid:type(def, "table", 2, false)
    self.parent.valid:not_empty(def, 2, false)
    self.parent.valid:type(delay, "number", 3, true)

    if delay then
      def = self.parent.table:map(def, function(_, element)
        element.delay = delay
        return element
      end)
    end

    -- Record the initial information
    multi_timers[name] = { def = def }

    local timer_result
    local timer_id = tempTimer(def[1].delay, function()
      timer_result = perform_multi_timer_function(self, name)
    end)

    if not timer_id then
      instance:kill_multi(name)
      return false
    end

    -- Record the timer id
    multi_timers[name].id = timer_id

    return true
  end

  --- Kills a multi timer by name.
  --- @param name string - The name of the multi timer.
  --- @return boolean|nil - True if the multi timer was killed, nil if it doesn't exist.
  --- @example
  --- ```lua
  --- timer.kill_multi("Greetings")
  --- ```
  function instance:kill_multi(name)
    self.parent.valid:type(name, "string", 1, false)
    local timer_function = multi_timers[name]
    if not timer_function then return nil end

    multi_timers[name] = nil
    local id = timer_function.id

    if id then
      return killTimer(id)
    end

    return true
  end

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
