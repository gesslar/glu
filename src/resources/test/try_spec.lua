describe("try module", function()
  local g

  setup(function()
    g = Glu("Glu")
  end)

  -- ========================================================================
  -- try
  -- ========================================================================

  describe("try", function()
    it("should execute a function successfully", function()
      local t = g.try(function() return 42 end)
      assert.is_truthy(t)
    end)

    it("should store result on success", function()
      local t = g.try(function() return 42 end)
      assert.are.equal(42, t.result.result)
    end)

    it("should mark caught as false on success", function()
      local t = g.try(function() return 42 end)
      assert.is_false(t.caught)
    end)

    it("should mark success as true on success", function()
      local t = g.try(function() return 42 end)
      assert.is_true(t.result.try.success)
    end)

    it("should mark caught as true on error", function()
      local t = g.try(function() error("boom") end)
      assert.is_true(t.caught)
    end)

    it("should mark success as false on error", function()
      local t = g.try(function() error("boom") end)
      assert.is_false(t.result.try.success)
    end)

    it("should store error message on error", function()
      local t = g.try(function() error("boom") end)
      assert.is_truthy(t.result.try.error)
    end)

    it("should set result to nil on error", function()
      local t = g.try(function() error("boom") end)
      assert.is_nil(t.result.try.result)
    end)

    it("should pass arguments to the function", function()
      local t = g.try(function(a, b) return a + b end, 10, 20)
      assert.are.equal(30, t.result.result)
    end)

    it("should handle function returning string", function()
      local t = g.try(function() return "hello" end)
      assert.are.equal("hello", t.result.result)
    end)

    it("should handle function returning table", function()
      local t = g.try(function() return {1, 2, 3} end)
      assert.are.same({1, 2, 3}, t.result.result)
    end)

    it("should handle function returning nil", function()
      local t = g.try(function() return nil end)
      assert.is_nil(t.result.result)
    end)

    it("should set error to nil on success", function()
      local t = g.try(function() return 42 end)
      assert.is_nil(t.result.try.error)
    end)

    it("should handle function returning false", function()
      local t = g.try(function() return false end)
      assert.is_false(t.result.try.result)
      assert.is_true(t.result.try.success)
    end)
  end)

  -- ========================================================================
  -- catch
  -- ========================================================================

  describe("catch", function()
    it("should call catch handler with try result", function()
      local caught_info
      g.try(function() error("boom") end)
        .catch(function(info) caught_info = info end)
      assert.is_truthy(caught_info)
      assert.is_true(caught_info.caught)
    end)

    it("should pass error in catch handler info", function()
      local caught_error
      g.try(function() error("boom") end)
        .catch(function(info) caught_error = info.error end)
      assert.is_truthy(caught_error)
    end)

    it("should call catch even on success", function()
      local called = false
      g.try(function() return 42 end)
        .catch(function(info) called = true end)
      assert.is_true(called)
    end)

    it("should show caught as false when try succeeded", function()
      local was_caught
      g.try(function() return 42 end)
        .catch(function(info) was_caught = info.caught end)
      assert.is_false(was_caught)
    end)

    it("should return self for chaining", function()
      local t = g.try(function() return 42 end)
      local result = t.catch(function() end)
      assert.are.equal(t, result)
    end)

    it("should handle catch handler that errors", function()
      local t = g.try(function() error("original") end)
        .catch(function() error("catch error") end)
      assert.is_false(t.result.catch.success)
    end)
  end)

  -- ========================================================================
  -- finally
  -- ========================================================================

  describe("finally", function()
    it("should call finally after try", function()
      local called = false
      g.try(function() return 42 end)
        .finally(function() called = true end)
      assert.is_true(called)
    end)

    it("should call finally after try and catch", function()
      local called = false
      g.try(function() error("boom") end)
        .catch(function() end)
        .finally(function() called = true end)
      assert.is_true(called)
    end)

    it("should pass full result to finally handler", function()
      local finally_result
      g.try(function() return 42 end)
        .finally(function(r) finally_result = r end)
      assert.is_truthy(finally_result)
      assert.is_truthy(finally_result.try)
    end)

    it("should include catch info when catch was called", function()
      local finally_result
      g.try(function() error("boom") end)
        .catch(function() end)
        .finally(function(r) finally_result = r end)
      assert.is_truthy(finally_result.catch)
    end)

    it("should error if finally handler errors", function()
      assert.has_error(function()
        g.try(function() return 42 end)
          .finally(function() error("finally broke") end)
      end)
    end)

    it("should return self for chaining", function()
      local t = g.try(function() return 42 end)
      local result = t.finally(function() end)
      assert.are.equal(t, result)
    end)
  end)

  -- ========================================================================
  -- Chaining
  -- ========================================================================

  describe("chaining", function()
    it("should support try/catch/finally chain", function()
      local order = {}
      g.try(function()
        table.insert(order, "try")
        error("boom")
      end)
        .catch(function()
          table.insert(order, "catch")
        end)
        .finally(function()
          table.insert(order, "finally")
        end)
      assert.are.same({"try", "catch", "finally"}, order)
    end)

    it("should support try/finally without catch", function()
      local order = {}
      g.try(function()
        table.insert(order, "try")
        return 42
      end)
        .finally(function()
          table.insert(order, "finally")
        end)
      assert.are.same({"try", "finally"}, order)
    end)

    it("should support successful try/catch/finally chain", function()
      local order = {}
      g.try(function()
        table.insert(order, "try")
        return 42
      end)
        .catch(function()
          table.insert(order, "catch")
        end)
        .finally(function()
          table.insert(order, "finally")
        end)
      assert.are.same({"try", "catch", "finally"}, order)
    end)
  end)

  -- ========================================================================
  -- clone
  -- ========================================================================

  describe("clone", function()
    it("should create independent try instances", function()
      local t1 = g.try(function() return 1 end)
      local t2 = g.try(function() return 2 end)
      assert.are.equal(1, t1.result.result)
      assert.are.equal(2, t2.result.result)
    end)

    it("should not share state between instances", function()
      local t1 = g.try(function() error("boom") end)
      local t2 = g.try(function() return "ok" end)
      assert.is_true(t1.caught)
      assert.is_false(t2.caught)
    end)
  end)
end)
