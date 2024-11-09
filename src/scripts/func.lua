local FuncClass = Glu.glass.register({
  name = "func",
  class_name = "FuncClass",
  dependencies = { "valid" },
  setup = function(___, self)
    function self.delay(func, delay, ...)
      ___.valid.type(func, "function", 1, false)
      ___.valid.type(delay, "number", 2, false)

      ---@diagnostic disable-next-line: return-type-mismatch
      return tempTimer(delay, function(...)
        func(...)
      end)
    end

    function self.wrap(func, wrapper)
      --- ```lua
      --- local becho = function.wrap(cecho, function(func, text)
      ---   func("<b>{text}</b>")
      --- end)
      ---
      --- becho("Hello, world!")
      --- -- <b>Hello, world!</b>
      --- ```
      ___.valid.type(func, "function", 1, false)
      ___.valid.type(wrapper, "function", 2, false)

      return function(...)
        return wrapper(func, ...)
      end
    end

    function self.repeater(func, interval, times, ...)
      ___.valid.type(func, "function", 1, false)
      ___.valid.type(interval, "number", 2, true)
      ___.valid.type(times, "number", 3, true)

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
  end
})