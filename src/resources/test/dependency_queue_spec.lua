describe("dependency_queue module", function()
  local g
  local installed

  setup(function()
    g = Glu("Glu")
    installed = getPackages()
  end)

  describe("new_dependency_queue", function()
    describe("when all packages are already installed", function()
      it("should call callback with true", function()
        if #installed == 0 then
          pending("no packages installed to test with")
          return
        end

        local cb_success = nil
        local packages = {}
        for i = 1, math.min(#installed, 2) do
          table.insert(packages, {name = installed[i], url = "https://example.com/" .. installed[i]})
        end

        g.dependency_queue.new_dependency_queue(
          packages,
          function(success, message)
            cb_success = success
          end
        )

        assert.is_true(cb_success)
      end)

      it("should pass the correct message to callback", function()
        if #installed == 0 then
          pending("no packages installed to test with")
          return
        end

        local cb_message = nil

        g.dependency_queue.new_dependency_queue(
          {{name = installed[1], url = "https://example.com/" .. installed[1]}},
          function(success, message)
            cb_message = message
          end
        )

        assert.are.equal("All dependencies are already installed.", cb_message)
      end)

      it("should not return self", function()
        if #installed == 0 then
          pending("no packages installed to test with")
          return
        end

        local result = g.dependency_queue.new_dependency_queue(
          {{name = installed[1], url = "https://example.com/" .. installed[1]}},
          function() end
        )

        assert.is_nil(result)
      end)
    end)

    describe("when packages need installing", function()
      local result

      before_each(function()
        result = g.dependency_queue.new_dependency_queue(
          {{name = "__glu_test_fake_pkg__", url = "https://example.com/fake"}},
          function() end
        )
      end)

      after_each(function()
        if result and result.clean_up then
          result.clean_up()
        end
      end)

      it("should return self", function()
        assert.is_truthy(result)
      end)

      it("should have a start method", function()
        assert.are.equal("function", type(result.start))
      end)

      it("should have a clean_up method", function()
        assert.are.equal("function", type(result.clean_up))
      end)

      it("should have a queue", function()
        assert.is_truthy(result.queue)
      end)

      it("should have a handler_name", function()
        assert.is_truthy(result.handler_name)
      end)

      it("should have the filtered packages list", function()
        assert.are.equal(1, #result.packages)
        assert.are.equal("__glu_test_fake_pkg__", result.packages[1].name)
      end)
    end)

    describe("with multiple uninstalled packages", function()
      it("should include all uninstalled packages", function()
        local result = g.dependency_queue.new_dependency_queue(
          {
            {name = "__glu_test_multi_a__", url = "https://example.com/a"},
            {name = "__glu_test_multi_b__", url = "https://example.com/b"},
            {name = "__glu_test_multi_c__", url = "https://example.com/c"},
          },
          function() end
        )

        assert.are.equal(3, #result.packages)
        result.clean_up()
      end)

      it("should filter out already-installed packages", function()
        if #installed == 0 then
          pending("no packages installed to test with")
          return
        end

        local result = g.dependency_queue.new_dependency_queue(
          {
            {name = installed[1], url = "https://example.com/" .. installed[1]},
            {name = "__glu_test_mixed__", url = "https://example.com/fake"},
          },
          function() end
        )

        assert.are.equal(1, #result.packages)
        assert.are.equal("__glu_test_mixed__", result.packages[1].name)
        result.clean_up()
      end)
    end)
  end)

  describe("clean_up", function()
    it("should nil out the queue", function()
      local result = g.dependency_queue.new_dependency_queue(
        {{name = "__glu_test_fake_cleanup_q__", url = "https://example.com/fake"}},
        function() end
      )

      result.clean_up()

      assert.is_nil(result.queue)
    end)

    it("should nil out the handler_name", function()
      local result = g.dependency_queue.new_dependency_queue(
        {{name = "__glu_test_fake_cleanup_h__", url = "https://example.com/fake"}},
        function() end
      )

      result.clean_up()

      assert.is_nil(result.handler_name)
    end)
  end)

  describe("install flow", function()
    local real_installPackage
    local real_tempTimer

    before_each(function()
      real_installPackage = _G.installPackage
      real_tempTimer = _G.tempTimer

      -- Mock tempTimer to execute callback immediately (same pattern as Mudlet's own tests)
      _G.tempTimer = function(time, code)
        if type(code) == "function" then
          code()
        elseif type(code) == "string" then
          loadstring(code)()
        end
      end

      -- Mock installPackage to do nothing — we fire sysInstall manually
      _G.installPackage = function() end
    end)

    after_each(function()
      _G.installPackage = real_installPackage
      _G.tempTimer = real_tempTimer

      -- Clean up the test package if it somehow got installed
      if table.index_of(getPackages(), "ThreshCopy") then
        uninstallPackage("ThreshCopy")
      end
    end)

    it("should complete when sysInstall fires for the package", function()
      local cb_success = nil
      local cb_message = nil

      local dq = g.dependency_queue.new_dependency_queue(
        {{name = "ThreshCopy", url = "https://example.com/fake"}},
        function(success, message)
          cb_success = success
          cb_message = message
        end
      )

      dq.start()

      -- Simulate Mudlet firing sysInstall after the package installs
      raiseEvent("sysInstall", "ThreshCopy")

      assert.is_true(cb_success)
      assert.is_nil(cb_message)
    end)

    it("should call callback with false on download error", function()
      local cb_success = nil
      local cb_message = nil

      g.dependency_queue.new_dependency_queue(
        {{name = "ThreshCopy", url = "https://example.com/fake"}},
        function(success, message)
          cb_success = success
          cb_message = message
        end
      )

      -- Simulate Mudlet firing sysDownloadError
      raiseEvent("sysDownloadError", "ThreshCopy")

      assert.is_false(cb_success)
      assert.is_truthy(cb_message)
    end)

    it("should install multiple packages in sequence", function()
      local cb_success = nil

      local dq = g.dependency_queue.new_dependency_queue(
        {
          {name = "FakePkgA", url = "https://example.com/a"},
          {name = "FakePkgB", url = "https://example.com/b"},
        },
        function(success, message)
          cb_success = success
        end
      )

      dq.start()

      -- First package installs
      raiseEvent("sysInstall", "FakePkgA")
      -- Second package installs
      raiseEvent("sysInstall", "FakePkgB")

      assert.is_true(cb_success)
    end)
  end)

  describe("empty package list", function()
    it("should call callback with true immediately", function()
      local cb_success = nil
      local cb_message = nil

      g.dependency_queue.new_dependency_queue(
        {},
        function(success, message)
          cb_success = success
          cb_message = message
        end
      )

      assert.is_true(cb_success)
      assert.are.equal("All dependencies are already installed.", cb_message)
    end)

    it("should not return self", function()
      local result = g.dependency_queue.new_dependency_queue(
        {},
        function() end
      )

      assert.is_nil(result)
    end)
  end)

  describe("install flow edge cases", function()
    local real_installPackage
    local real_tempTimer

    before_each(function()
      real_installPackage = _G.installPackage
      real_tempTimer = _G.tempTimer

      _G.tempTimer = function(time, code)
        if type(code) == "function" then
          code()
        elseif type(code) == "string" then
          loadstring(code)()
        end
      end

      _G.installPackage = function() end
    end)

    after_each(function()
      _G.installPackage = real_installPackage
      _G.tempTimer = real_tempTimer
    end)

    it("should ignore sysInstall for non-matching package names", function()
      local cb_success = nil

      local dq = g.dependency_queue.new_dependency_queue(
        {{name = "FakePkgX", url = "https://example.com/x"}},
        function(success, message)
          cb_success = success
        end
      )

      dq.start()

      -- Fire sysInstall for a different package — should be ignored
      raiseEvent("sysInstall", "SomeOtherPackage")

      assert.is_nil(cb_success)
      dq.clean_up()
    end)

    it("should handle download error on first of multiple packages", function()
      local cb_success = nil
      local cb_message = nil

      local dq = g.dependency_queue.new_dependency_queue(
        {
          {name = "FakePkgFirst", url = "https://example.com/first"},
          {name = "FakePkgSecond", url = "https://example.com/second"},
        },
        function(success, message)
          cb_success = success
          cb_message = message
        end
      )

      dq.start()

      -- First package fails to download
      raiseEvent("sysDownloadError", "FakePkgFirst")

      assert.is_false(cb_success)
      assert.is_truthy(cb_message)
    end)

    it("should handle download error on second of multiple packages", function()
      local cb_success = nil
      local cb_message = nil

      local dq = g.dependency_queue.new_dependency_queue(
        {
          {name = "FakePkgAlpha", url = "https://example.com/alpha"},
          {name = "FakePkgBeta", url = "https://example.com/beta"},
        },
        function(success, message)
          cb_success = success
          cb_message = message
        end
      )

      dq.start()

      -- First package succeeds
      raiseEvent("sysInstall", "FakePkgAlpha")

      -- Reset to check second callback
      cb_success = nil
      cb_message = nil

      -- Second package fails
      raiseEvent("sysDownloadError", "FakePkgBeta")

      assert.is_false(cb_success)
      assert.is_truthy(cb_message)
    end)

    it("should clean up event handlers after successful install", function()
      local dq = g.dependency_queue.new_dependency_queue(
        {{name = "FakePkgCleanup", url = "https://example.com/cleanup"}},
        function() end
      )

      local handler_name = dq.handler_name
      dq.start()
      raiseEvent("sysInstall", "FakePkgCleanup")

      -- After completion, handler_name should be nil (cleaned up)
      assert.is_nil(dq.handler_name)
      assert.is_nil(dq.queue)
    end)

    it("should clean up event handlers after download error", function()
      local dq = g.dependency_queue.new_dependency_queue(
        {{name = "FakePkgErrClean", url = "https://example.com/errclean"}},
        function() end
      )

      dq.start()
      raiseEvent("sysDownloadError", "FakePkgErrClean")

      assert.is_nil(dq.handler_name)
      assert.is_nil(dq.queue)
    end)
  end)

  describe("start", function()
    it("should return nil after clean_up", function()
      local result = g.dependency_queue.new_dependency_queue(
        {{name = "__glu_test_fake_start_nil__", url = "https://example.com/fake"}},
        function() end
      )

      result.clean_up()
      local start_result = result.start()

      assert.is_nil(start_result)
    end)

    it("should return error message after clean_up", function()
      local result = g.dependency_queue.new_dependency_queue(
        {{name = "__glu_test_fake_start_err__", url = "https://example.com/fake"}},
        function() end
      )

      result.clean_up()
      local _, err = result.start()

      assert.are.equal("Queue not found", err)
    end)
  end)
end)
