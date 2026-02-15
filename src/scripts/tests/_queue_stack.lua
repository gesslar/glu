---@diagnostic disable-next-line: lowercase-global
function run_queue_stack_tests()
  -- This is a test for the queue_stack module.
  local tester_name = "__PKGNAME__"
  local g = Glu(tester_name)
  local testing = g.queue
  local test = g.test

  local function push_adds_function(cond)
    local queue = testing.new_queue()
    local result = nil
    queue.push(function() result = "pushed" end)
    queue.execute()
    return cond.is_eq(
      result,
      "pushed",
      "push() should add a function to the queue that can be executed"
    )
  end

  local function shift_removes_first_function(cond)
    local queue = testing.new_queue({
      function() return "first" end,
      function() return "second" end,
    })
    local shifted = queue.shift()
    return cond.is_eq(
      shifted(),
      "first",
      "shift() should remove and return the first function in the queue"
    )
  end

  local function execute_runs_first_task(cond)
    local result = nil
    local queue = testing.new_queue({
      function(self) result = "executed" end,
    })
    queue.execute()
    return cond.is_eq(
      result,
      "executed",
      "execute() should run the first task in the queue"
    )
  end

  local function execute_returns_remaining_count(cond)
    local queue = testing.new_queue({
      function(self) end,
      function(self) end,
      function(self) end,
    })
    local _, count = queue.execute()
    return cond.is_eq(
      count,
      2,
      "execute() should return the remaining task count"
    )
  end

  local function execute_returns_nil_when_last_task(cond)
    local queue = testing.new_queue({
      function(self) end,
    })
    local _, count = queue.execute()
    return cond.is_nil(
      count,
      "execute() should return nil for count when no tasks remain"
    )
  end

  local function execute_returns_nil_when_empty(cond)
    local queue = testing.new_queue()
    local _, count = queue.execute()
    return cond.is_nil(
      count,
      "execute() should return nil for count when queue is empty"
    )
  end

  local function execute_returns_task_result(cond)
    local queue = testing.new_queue({
      function(self) return "task_result" end,
    })
    local _, _, result = queue.execute()
    return cond.is_eq(
      result,
      "task_result",
      "execute() should return the result of the executed task"
    )
  end

  local function execute_passes_arguments(cond)
    local received = nil
    local queue = testing.new_queue({
      function(self, arg) received = arg end,
    })
    queue.execute("test_arg")
    return cond.is_eq(
      received,
      "test_arg",
      "execute() should pass arguments to the executed task"
    )
  end

  local function execute_fifo_order(cond)
    local results = {}
    local queue = testing.new_queue({
      function(self) table.insert(results, "first") end,
      function(self) table.insert(results, "second") end,
      function(self) table.insert(results, "third") end,
    })
    queue.execute()
    queue.execute()
    queue.execute()
    return cond.is_deeply(
      results,
      { "first", "second", "third" },
      "execute() should process tasks in FIFO order"
    )
  end

  local function execute_returns_self(cond)
    local queue = testing.new_queue({
      function(self) end,
    })
    local returned = queue.execute()
    return cond.is_eq(
      returned,
      queue,
      "execute() should return the queue object itself"
    )
  end

  -- Run the tests
  local runner = test.runner({
        name = "queue_stack",
        tests = {
          { name = "queue_stack.push_adds_function",           func = push_adds_function },
          { name = "queue_stack.shift_removes_first_function", func = shift_removes_first_function },
          { name = "queue_stack.execute_runs_first_task",      func = execute_runs_first_task },
          { name = "queue_stack.execute_returns_remaining",    func = execute_returns_remaining_count },
          { name = "queue_stack.execute_returns_nil_last",     func = execute_returns_nil_when_last_task },
          { name = "queue_stack.execute_returns_nil_empty",    func = execute_returns_nil_when_empty },
          { name = "queue_stack.execute_returns_task_result",  func = execute_returns_task_result },
          { name = "queue_stack.execute_passes_arguments",     func = execute_passes_arguments },
          { name = "queue_stack.execute_fifo_order",           func = execute_fifo_order },
          { name = "queue_stack.execute_returns_self",         func = execute_returns_self },
        },
      })
      .execute(true)
      .wipe()
end
