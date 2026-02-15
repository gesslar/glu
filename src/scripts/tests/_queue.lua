---@diagnostic disable-next-line: lowercase-global
function run_queue_tests()
  -- This is a test for the queue module.
  local tester_name = "__PKGNAME__"
  local g = Glu(tester_name)
  local testing = g.queue
  local test = g.test

  local function new_queue_returns_queue(cond)
    local queue = testing.new_queue()
    return cond.is_not_nil(
      queue,
      "new_queue() should return a queue object"
    )
  end

  local function new_queue_has_id(cond)
    local queue = testing.new_queue()
    return cond.is_type(
      queue.id,
      "string",
      "new_queue() should create a queue with a string id"
    )
  end

  local function new_queue_added_to_registry(cond)
    local before = #testing.queues
    testing.new_queue()
    return cond.is_eq(
      #testing.queues,
      before + 1,
      "new_queue() should add the queue to the registry"
    )
  end

  local function new_queue_with_initial_functions(cond)
    local called = false
    local queue = testing.new_queue({
      function(self) called = true end,
    })
    queue.execute()
    return cond.is_true(
      called,
      "new_queue() should accept and store initial functions"
    )
  end

  local function get_returns_queue_by_id(cond)
    local queue = testing.new_queue()
    local found = testing.get(queue.id)
    return cond.is_eq(
      found,
      queue,
      "get() should return the queue matching the given id"
    )
  end

  local function get_returns_nil_for_unknown_id(cond)
    local result = testing.get("00000000-0000-0000-0000-000000000000")
    return cond.is_nil(
      result,
      "get() should return nil for an unknown id"
    )
  end

  local function push_by_id_adds_function(cond)
    local queue = testing.new_queue()
    local result = nil
    testing.push(queue.id, function(self) result = "pushed_via_id" end)
    queue.execute()
    return cond.is_eq(
      result,
      "pushed_via_id",
      "push() should add a function to a queue found by id"
    )
  end

  local function push_returns_nil_for_unknown_id(cond)
    local result = testing.push("00000000-0000-0000-0000-000000000000", function() end)
    return cond.is_nil(
      result,
      "push() should return nil for an unknown queue id"
    )
  end

  local function shift_by_id_removes_function(cond)
    local queue = testing.new_queue({
      function() return "shifted" end,
    })
    local shifted = testing.shift(queue.id)
    return cond.is_eq(
      shifted(),
      "shifted",
      "shift() should remove and return the first function from the queue found by id"
    )
  end

  local function shift_returns_nil_for_unknown_id(cond)
    local result = testing.shift("00000000-0000-0000-0000-000000000000")
    return cond.is_nil(
      result,
      "shift() should return nil for an unknown queue id"
    )
  end

  -- Run the tests
  local runner = test.runner({
        name = "queue",
        tests = {
          { name = "queue.new_queue_returns_queue",          func = new_queue_returns_queue },
          { name = "queue.new_queue_has_id",                 func = new_queue_has_id },
          { name = "queue.new_queue_added_to_registry",      func = new_queue_added_to_registry },
          { name = "queue.new_queue_with_initial_functions", func = new_queue_with_initial_functions },
          { name = "queue.get_returns_queue_by_id",          func = get_returns_queue_by_id },
          { name = "queue.get_returns_nil_for_unknown_id",   func = get_returns_nil_for_unknown_id },
          { name = "queue.push_by_id_adds_function",         func = push_by_id_adds_function },
          { name = "queue.push_returns_nil_for_unknown_id",  func = push_returns_nil_for_unknown_id },
          { name = "queue.shift_by_id_removes_function",     func = shift_by_id_removes_function },
          { name = "queue.shift_returns_nil_for_unknown_id", func = shift_returns_nil_for_unknown_id },
        },
      })
      .execute(true)
      .wipe()
end
