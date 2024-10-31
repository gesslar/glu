-- The script name
local script_name = "queue"
local deps = { "table", "valid" }

local QueueClass = {}
function QueueClass.new(parent, funcs)
  local instance = {
    parent = parent,
    ___ = (function(p)
      while p.parent do p = p.parent end
      return p
    end)(parent)
  }

  instance.___.valid:type(funcs, "table", 2, false)
  funcs = funcs or {}
  funcs = instance.___.table:n_cast(funcs)
  instance.___.valid:n_uniform(funcs, "function", 2, false)
  instance.stack = funcs

  setmetatable({
    parent = parent,
    id = instance.___.util:generate_uuid(),
    stack = funcs,
  }, instance)

  function instance:push(f)
    self.___.valid:type(f, "function", 1, false)
    return self.___.table:push(self.stack, f)
  end

  function instance:shift()
    return self.___.table:shift(self.stack)
  end

  function instance:next()
    local index = 0

    return function()
      index = index + 1
      if index <= #self.stack then
        return self.stack[index]
      end
    end
  end

  function instance:execute(...)
    -- Shift the next task off the queue
    local task = self:shift()
    if not task then
      return self, nil -- Queue is empty, return nil for remaining count
    end

    -- Execute the task with the provided arguments and store the result(s)
    local result = { task(self, ...) }

    -- Determine remaining task count, returning nil if no tasks remain
    local count = #self.stack
    return self, count > 0 and count or nil, unpack(result)
  end

  return instance
end

---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
function mod.new(parent)
  local instance = setmetatable({
    parent = parent,
    queue = QueueClass,
    queues = {},
    ___ = (function(p)
      while p.parent do p = p.parent end
      return p
    end)(parent)
  }, { __index = mod })

  --- Instantiates a new queue object and adds it to the list of queues
  ---
  --- @param funcs table - A table of functions to be added to the queue
  --- @return table - The new queue object
  ---
  --- @example
  --- ```lua
  --- local queue = mod.new(parent).new({})
  --- ```
  function instance.new(funcs)
    instance.___.valid:type(funcs, "table", 1, true)
    instance.___.valid:n_uniform(funcs, "function", 1, false)

    funcs = funcs or {}
    local queue = instance.queue.new(instance, funcs)

    instance.___.table:push(instance.queues, queue)
    ---@diagnostic disable-next-line: return-type-mismatch
    return queue
  end

  function instance:get(id)
    self.___.valid:type(id, "string", 1, false)

    for _, q in pairs(self.queues) do
      if q.id == id then return q end
    end
    return nil, f"Queue not found for id `{id}`."
  end

  function instance:push(id, f)
    self.___.valid:type(id, "string", 1, false)
    self.___.valid:type(f, "function", 2, false)

    local q, err = self:get(id)
    if not q then return nil, err end

    return q:push(f)
  end

  function instance:shift(id)
    self.___.valid:type(id, "string", 1, false)

    local q, err = self:get(id)
    if not q then return nil, err end

    return q:shift()
  end

  function instance:next()
    local index = 0

    return function()
      index = index + 1
      if index <= #self.queues then
        return self.queues[index]
      end
    end
  end

  function instance:processQueueById(queueId)
    self.___.valid:type(queueId, "string", 1, false)
    local queue, err = self:get(queueId)
    self.___.valid:test(queue, err, 1, false)

    if not queue then
      print(err)
      return
    end

    -- Start or resume the queue's coroutine
    queue:processQueue()
  end

  function instance:processAllQueues()
    for queue in self:next() do
      queue:processQueue()
    end
  end

  -- Ensure that there is at least something to avoid errors until
  -- the modules this module depends upon are loaded.
  local f = function(_, k) return function(...) end end
  for _, d in ipairs(deps) do
    instance.___[d] = instance.___[d] or
      setmetatable({}, { __index = f })
  end

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
