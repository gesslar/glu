---@diagnostic disable-next-line: lowercase-global
function run_dependency_queue_tests()
  -- This is a test for the dependency_queue module.
  local tester_name = "__PKGNAME__"
  local g = Glu(tester_name)
  local testing = g.dependency_queue
  local test = g.test

  -- Use actually installed packages for "already installed" tests
  local installed = getPackages()

  local function all_installed_calls_callback(cond)
    -- When all packages are already installed, the callback should fire
    -- immediately with success.
    local cb_success = nil

    if #installed == 0 then
      -- No packages installed; skip meaningfully by passing
      return cond.is_true(true, "skipped: no packages installed to test with")
    end

    local packages = {}
    for i = 1, math.min(#installed, 2) do
      table.insert(packages, { name = installed[i], url = "https://example.com/" .. installed[i] })
    end

    testing.new_dependency_queue(
      packages,
      function(success, message)
        cb_success = success
      end
    )

    return cond.is_true(
      cb_success,
      "new_dependency_queue() should call callback with true when all packages are installed"
    )
  end

  local function all_installed_message(cond)
    local cb_message = nil

    if #installed == 0 then
      return cond.is_true(true, "skipped: no packages installed to test with")
    end

    testing.new_dependency_queue(
      {
        { name = installed[1], url = "https://example.com/" .. installed[1] },
      },
      function(success, message)
        cb_message = message
      end
    )

    return cond.is_eq(
      cb_message,
      "All dependencies are already installed.",
      "new_dependency_queue() should return the correct message when all packages are installed"
    )
  end

  local function returns_self_when_not_installed(cond)
    local result = testing.new_dependency_queue(
      {
        { name = "__glu_test_fake_pkg__", url = "https://example.com/fake" },
      },
      function() end
    )

    local has_result = result ~= nil
    if result then result.clean_up() end

    return cond.is_true(
      has_result,
      "new_dependency_queue() should return self when packages need installing"
    )
  end

  local function has_start_method(cond)
    local result = testing.new_dependency_queue(
      {
        { name = "__glu_test_fake_pkg_start__", url = "https://example.com/fake" },
      },
      function() end
    )

    local has_start = type(result.start) == "function"
    result.clean_up()

    return cond.is_true(
      has_start,
      "new_dependency_queue() should return an object with a start() method"
    )
  end

  local function has_clean_up_method(cond)
    local result = testing.new_dependency_queue(
      {
        { name = "__glu_test_fake_pkg_cleanup__", url = "https://example.com/fake" },
      },
      function() end
    )

    local has_cleanup = type(result.clean_up) == "function"
    result.clean_up()

    return cond.is_true(
      has_cleanup,
      "new_dependency_queue() should return an object with a clean_up() method"
    )
  end

  local function clean_up_nils_queue(cond)
    local result = testing.new_dependency_queue(
      {
        { name = "__glu_test_fake_pkg_nilq__", url = "https://example.com/fake" },
      },
      function() end
    )

    result.clean_up()

    return cond.is_nil(
      result.queue,
      "clean_up() should nil out the queue"
    )
  end

  local function clean_up_nils_handler_name(cond)
    local result = testing.new_dependency_queue(
      {
        { name = "__glu_test_fake_pkg_nilh__", url = "https://example.com/fake" },
      },
      function() end
    )

    result.clean_up()

    return cond.is_nil(
      result.handler_name,
      "clean_up() should nil out the handler_name"
    )
  end

  local function start_returns_nil_after_cleanup(cond)
    local result = testing.new_dependency_queue(
      {
        { name = "__glu_test_fake_pkg_startnil__", url = "https://example.com/fake" },
      },
      function() end
    )

    result.clean_up()
    local start_result, err = result.start()

    return cond.is_nil(
      start_result,
      "start() should return nil after clean_up() has been called"
    )
  end

  -- Run the tests
  local runner = test.runner({
        name = "dependency_queue",
        tests = {
          { name = "dependency_queue.all_installed_calls_cb",     func = all_installed_calls_callback },
          { name = "dependency_queue.all_installed_message",      func = all_installed_message },
          { name = "dependency_queue.returns_self_not_installed", func = returns_self_when_not_installed },
          { name = "dependency_queue.has_start_method",           func = has_start_method },
          { name = "dependency_queue.has_clean_up_method",        func = has_clean_up_method },
          { name = "dependency_queue.clean_up_nils_queue",        func = clean_up_nils_queue },
          { name = "dependency_queue.clean_up_nils_handler",      func = clean_up_nils_handler_name },
          { name = "dependency_queue.start_nil_after_cleanup",    func = start_returns_nil_after_cleanup },
        },
      })
      .execute(true)
      .wipe()
end
