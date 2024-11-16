local QueueStackClass = Glu.glass.register({
  name = "queue_stack",
  class_name = "QueueStackClass",
  dependencies = { "table" },
  setup = function(___, self, opts, container)
    if not opts.funcs then return end

    local funcs = opts.funcs or {}

    funcs = ___.table.n_cast(funcs)
    ___.v.n_uniform(funcs, "function", 2, false)

    self.stack = funcs
    self.id = ___.id()

    function self.push(f)
      ___.v.type(f, "function", 1, false)
      return ___.table.push(self.stack, f)
    end

    function self.shift()
      return ___.table.shift(self.stack)
    end

    function self.execute(...)
      -- Shift the next task off the queue
      local task = self.shift()
      if not task then
        return self, nil -- Queue is empty, return nil for remaining count
      end

      -- Execute the task with the provided arguments and store the result(s)
      local result = { task(self, ...) }

      -- Determine remaining task count, returning nil if no tasks remain
      local count = #self.stack
      return self, count > 0 and count or nil, unpack(result)
    end
  end
})
