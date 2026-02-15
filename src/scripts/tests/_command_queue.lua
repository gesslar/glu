---@diagnostic disable-next-line: lowercase-global
function run_command_queue_tests()
  -- This is a test for the command_queue module.
  local tester_name = "__PKGNAME__"
  local g = Glu(tester_name)
  local testing = g.command_queue
  local test = g.test

  local function states_exist(cond)
    return cond.is_not_nil(
      testing.states,
      "states should be defined on the command queue"
    )
  end

  local function states_running(cond)
    return cond.is_eq(
      testing.states.RUNNING,
      1,
      "states.RUNNING should equal 1"
    )
  end

  local function states_paused(cond)
    return cond.is_eq(
      testing.states.PAUSED,
      2,
      "states.PAUSED should equal 2"
    )
  end

  local function states_stopped(cond)
    return cond.is_eq(
      testing.states.STOPPED,
      3,
      "states.STOPPED should equal 3"
    )
  end

  local function states_error(cond)
    return cond.is_eq(
      testing.states.ERROR,
      -math.huge,
      "states.ERROR should equal -math.huge"
    )
  end

  local function queue_requires_name(cond)
    return cond.is_error(
      function() testing.queue(nil, "test", 1) end,
      "queue() should require a name parameter"
    )
  end

  local function queue_requires_delay(cond)
    return cond.is_error(
      function() testing.queue("test_q", "test", nil) end,
      "queue() should require a delay parameter"
    )
  end

  local function queue_rejects_negative_delay(cond)
    return cond.is_error(
      function() testing.queue("test_neg", "test", -1) end,
      "queue() should reject a negative delay"
    )
  end

  -- Run the tests
  local runner = test.runner({
        name = "command_queue",
        tests = {
          { name = "command_queue.states_exist",            func = states_exist },
          { name = "command_queue.states_running",          func = states_running },
          { name = "command_queue.states_paused",           func = states_paused },
          { name = "command_queue.states_stopped",          func = states_stopped },
          { name = "command_queue.states_error",            func = states_error },
          { name = "command_queue.queue_requires_name",     func = queue_requires_name },
          { name = "command_queue.queue_requires_delay",    func = queue_requires_delay },
          { name = "command_queue.queue_rejects_neg_delay", func = queue_rejects_negative_delay },
        },
      })
      .execute(true)
      .wipe()
end
