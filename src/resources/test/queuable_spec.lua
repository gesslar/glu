describe("queuable module", function()
  local g

  setup(function()
    g = Glu("Glu")
  end)

  -- queuable is a mixin class that adopts push/shift/pop/unshift from
  -- table and initializes a stack property. It requires the glass system
  -- to instantiate with a proper container. We test it through a
  -- queue_stack which exercises the same underlying table operations.

  -- ========================================================================
  -- stack initialization
  -- ========================================================================

  describe("stack property", function()
    it("should exist on queue_stack instances", function()
      local qs = g.queue.new_queue({})
      assert.is_truthy(qs.stack)
      assert.are.equal("table", type(qs.stack))
    end)

    it("should start empty when no funcs provided", function()
      local qs = g.queue.new_queue({})
      assert.are.equal(0, #qs.stack)
    end)
  end)

  -- ========================================================================
  -- Adopted methods (push/shift/pop/unshift from table)
  -- ========================================================================

  describe("adopted methods", function()
    it("should have push available", function()
      local qs = g.queue.new_queue({})
      assert.are.equal("function", type(qs.push))
    end)

    it("should have shift available", function()
      local qs = g.queue.new_queue({})
      assert.are.equal("function", type(qs.shift))
    end)

    it("push should add to end of stack", function()
      local qs = g.queue.new_queue({})
      qs.push(function() return "a" end)
      qs.push(function() return "b" end)
      assert.are.equal(2, #qs.stack)
      assert.are.equal("a", qs.stack[1]())
      assert.are.equal("b", qs.stack[2]())
    end)

    it("shift should remove from front of stack", function()
      local f1 = function() return 1 end
      local f2 = function() return 2 end
      local qs = g.queue.new_queue({f1, f2})
      local shifted = qs.shift()
      assert.are.equal(f1, shifted)
      assert.are.equal(1, #qs.stack)
      assert.are.equal(f2, qs.stack[1])
    end)
  end)
end)
