describe("queue_stack module", function()
  local g

  setup(function()
    g = Glu("Glu")
  end)

  -- queue_stack instances are created through g.queue.new_queue()

  -- ========================================================================
  -- Construction
  -- ========================================================================

  describe("construction", function()
    it("should create an empty queue_stack", function()
      local qs = g.queue.new_queue({})
      assert.is_truthy(qs)
      assert.are.equal(0, #qs.stack)
    end)

    it("should create a queue_stack with initial functions", function()
      local qs = g.queue.new_queue({function() end, function() end})
      assert.are.equal(2, #qs.stack)
    end)

    it("should assign an id", function()
      local qs = g.queue.new_queue({})
      assert.is_truthy(qs.id)
      assert.are.equal("string", type(qs.id))
    end)

    it("should create with nil funcs (defaults to empty)", function()
      local qs = g.queue.new_queue()
      assert.is_truthy(qs)
      assert.are.equal(0, #qs.stack)
    end)

    it("should error if funcs contains non-functions", function()
      assert.has_error(function()
        g.queue.new_queue({function() end, "not a function"})
      end)
    end)
  end)

  -- ========================================================================
  -- push
  -- ========================================================================

  describe("push", function()
    it("should add a function to the stack", function()
      local qs = g.queue.new_queue({})
      qs.push(function() end)
      assert.are.equal(1, #qs.stack)
    end)

    it("should return the new count", function()
      local qs = g.queue.new_queue({function() end})
      local count = qs.push(function() end)
      assert.are.equal(2, count)
    end)

    it("should add to the end (FIFO order)", function()
      local order = {}
      local qs = g.queue.new_queue({function() table.insert(order, "first") end})
      qs.push(function() table.insert(order, "second") end)
      qs.shift()() -- execute first
      qs.shift()() -- execute second
      assert.are.same({"first", "second"}, order)
    end)

    it("should error on non-function argument", function()
      local qs = g.queue.new_queue({})
      assert.has_error(function()
        qs.push("not a function")
      end)
    end)

    it("should error on nil argument", function()
      local qs = g.queue.new_queue({})
      assert.has_error(function()
        qs.push(nil)
      end)
    end)
  end)

  -- ========================================================================
  -- shift
  -- ========================================================================

  describe("shift", function()
    it("should remove and return the first function", function()
      local f1 = function() return 1 end
      local f2 = function() return 2 end
      local qs = g.queue.new_queue({f1, f2})
      local shifted = qs.shift()
      assert.are.equal(f1, shifted)
      assert.are.equal(1, #qs.stack)
    end)

    it("should return nil when empty", function()
      local qs = g.queue.new_queue({})
      local shifted = qs.shift()
      assert.is_nil(shifted)
    end)

    it("should shift in FIFO order", function()
      local results = {}
      local qs = g.queue.new_queue({
        function() return "a" end,
        function() return "b" end,
        function() return "c" end
      })
      table.insert(results, qs.shift()())
      table.insert(results, qs.shift()())
      table.insert(results, qs.shift()())
      assert.are.same({"a", "b", "c"}, results)
    end)
  end)

  -- ========================================================================
  -- execute
  -- ========================================================================

  describe("execute", function()
    it("should execute the first function in the queue", function()
      local called = false
      local qs = g.queue.new_queue({function() called = true end})
      qs.execute()
      assert.is_true(called)
    end)

    it("should pass arguments to the function", function()
      local captured
      local qs = g.queue.new_queue({function(self_ref, a, b) captured = a + b end})
      qs.execute(10, 20)
      assert.are.equal(30, captured)
    end)

    it("should pass self as first argument to the function", function()
      local captured_self
      local qs = g.queue.new_queue({function(s) captured_self = s end})
      qs.execute()
      assert.are.equal(qs, captured_self)
    end)

    it("should return self as first value", function()
      local qs = g.queue.new_queue({function() end})
      local returned_self = qs.execute()
      assert.are.equal(qs, returned_self)
    end)

    it("should return remaining count when tasks remain", function()
      local qs = g.queue.new_queue({function() end, function() end, function() end})
      local _, count = qs.execute()
      assert.are.equal(2, count)
    end)

    it("should return nil count when no tasks remain", function()
      local qs = g.queue.new_queue({function() end})
      local _, count = qs.execute()
      assert.is_nil(count)
    end)

    it("should return nil count when queue was already empty", function()
      local qs = g.queue.new_queue({})
      local _, count = qs.execute()
      assert.is_nil(count)
    end)

    it("should return function results after self and count", function()
      local qs = g.queue.new_queue({function() return "hello" end})
      local _, _, result = qs.execute()
      assert.are.equal("hello", result)
    end)

    it("should return multiple function results", function()
      local qs = g.queue.new_queue({function() return "a", "b" end})
      local _, _, r1, r2 = qs.execute()
      assert.are.equal("a", r1)
      assert.are.equal("b", r2)
    end)

    it("should execute in FIFO order across multiple calls", function()
      local order = {}
      local qs = g.queue.new_queue({
        function() table.insert(order, "first") end,
        function() table.insert(order, "second") end,
        function() table.insert(order, "third") end
      })
      qs.execute()
      qs.execute()
      qs.execute()
      assert.are.same({"first", "second", "third"}, order)
    end)

    it("should decrement count with each execution", function()
      local qs = g.queue.new_queue({function() end, function() end, function() end})
      local _, count1 = qs.execute()
      local _, count2 = qs.execute()
      local _, count3 = qs.execute()
      assert.are.equal(2, count1)
      assert.are.equal(1, count2)
      assert.is_nil(count3)
    end)
  end)
end)
