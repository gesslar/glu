local QueueStack = Glu.glass.register({
  name = "queue_stack",
  class_name = "QueueStackClass",
  dependencies = { "table", "valid" },
  setup = function(___, self, opts, container)

    if not opts.funcs then return end

    local funcs = opts.funcs or {}

    funcs = ___.table.n_cast(funcs)
    ___.valid:n_uniform(funcs, "function", 2, false)

    self.stack = funcs
    self.id = ___.id()

    function self.push(f)
      ___.valid.type(f, "function", 1, false)
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

local QueueClass = Glu.glass.register({
  name = "queue",
  class_name = "QueueClass",
  dependencies = { "table", "valid" },
  setup = function(___, self)
    self.queues = {}

    --- Instantiates a new queue object and adds it to the list of queues.
    --- The object will contain a property that is the ID may be used to
    --- manipulate the queue. The same functionality to manipulate the queue
    --- is available both through the queue object and the functions from
    --- this module. The ID is in the form of a v4 UUID.
    ---
    --- @param funcs table - A table of functions to be added to the queue
    --- @return table - The new queue object
    ---
    --- @example
    --- ```lua
    --- local queue = queue.new(parent).new({})
    --- ```
    function self.new(funcs)
      ___.valid.type(funcs, "table", 1, true)
      ___.valid:n_uniform(funcs, "function", 1, false)

      funcs = funcs or {}
      local queue = QueueStack(funcs, self)
      ___.table.push(self.queues, queue)

      ---@diagnostic disable-next-line: return-type-mismatch
      return queue
    end

    --- Retrieves a queue object by its identifier. If no queue is found, nil is
    --- returned, otherwise the queue object is returned.
    ---
    --- @param id string - The identifier of the queue to retrieve
    --- @return table|nil - The queue object or nil if not found
    function self.get(id)
      ___.valid.type(id, "string", 1, false)

      for _, q in pairs(self.queues) do
        if q.id == id then return q end
      end
      return nil, f"Queue not found for id `{id}`."
    end

    --- Add a function to the end of a queue by its identifier.
    ---
    --- @param id string - The identifier of the queue to add the function to
    --- @param f function - The function to add to the queue
    --- @example
    --- ```lua
    --- queue:push("2ce02d6a-36a8-45ab-a78e-7f909427e1d1",
    ---   function() print("Hello, world!")
    --- end)
    --- ```
    function self.push(id, f)
      ___.valid.type(id, "string", 1, false)
      ___.valid.type(f, "function", 2, false)

      local q, err = self:get(id)
      if not q then return nil, err end

      return q.push(f)
    end

    function self.shift(id)
      ___.valid.type(id, "string", 1, false)

      local q, err = self.get(id)
      if not q then return nil, err end

      return q.shift()
    end
  end
})
