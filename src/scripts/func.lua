local script_name = "func"
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

  function instance:delay(func, delay, ...)
    self.___.valid:type(func, "function", 1, false)
    self.___.valid:type(delay, "number", 2, false)

    tempTimer(delay, function(...)
      func(...)
    end)
  end

  --- Wraps a function with another function. Assigned to a variable, the
  --- wrapper can be called directly and performs the wrapped function.
  --- This is useful making custom functions that perform certain actions
  --- in a consistent way.
  --- @param func function - The function to wrap.
  --- @param wrapper function - The wrapper function.
  --- @return function - A new function that wraps the original function.
  --- @example
  --- ```lua
  --- local becho = function:wrap(cecho, function(func, text)
  ---   func("<b>{text}</b>")
  --- end)
  ---
  --- becho("Hello, world!")
  --- -- <b>Hello, world!</b>
  --- ```
  function instance:wrap(func, wrapper)
    self.___.valid:type(func, "function", 1, false)
    self.___.valid:type(wrapper, "function", 2, false)

    return function(...)
      return wrapper(func, ...)
    end
  end

  --- Repeats a function at a given interval for a specified number of times.
  --- @param func function - The function to repeat.
  --- @param interval number - The interval between each repetition. (Optional. Default is 1.)
  --- @param times number - The number of times to repeat the function. (Optional. Default is 1.)
  ---
  --- @example
  --- ```lua
  --- local i = 10
  --- local repeater = function:repeater(function()
  ---   i = i + 1
  ---   print(i)
  --- end, 1, 5)
  --- ```
  function instance:repeater(func, interval, times, ...)
    self.___.valid:type(func, "function", 1, false)
    self.___.valid:type(interval, "number", 2, true)
    self.___.valid:type(times, "number", 3, true)

    interval = interval or 1
    times = times or 1

    local count = 0
    local function _repeat(...)
      if count < times then
        func(...)
        count = count + 1
        tempTimer(interval, _repeat, ...)
      end
    end
    _repeat(...)
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
