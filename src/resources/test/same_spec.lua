describe("same module", function()
  local g

  setup(function()
    g = Glu("Glu")
  end)

  -- ========================================================================
  -- value_zero (NaN same, +0/-0 same)
  -- ========================================================================

  describe("value_zero", function()
    it("should return true for equal numbers", function()
      assert.is_true(g.same.value_zero(42, 42))
    end)

    it("should return false for different numbers", function()
      assert.is_false(g.same.value_zero(1, 2))
    end)

    it("should return true for equal strings", function()
      assert.is_true(g.same.value_zero("hello", "hello"))
    end)

    it("should return false for different strings", function()
      assert.is_false(g.same.value_zero("hello", "world"))
    end)

    it("should return true for both NaN", function()
      assert.is_true(g.same.value_zero(0/0, 0/0))
    end)

    it("should return false for NaN and number", function()
      assert.is_false(g.same.value_zero(0/0, 1))
    end)

    it("should treat +0 and -0 as the same", function()
      assert.is_true(g.same.value_zero(0, -0))
    end)

    it("should return false for different types", function()
      assert.is_false(g.same.value_zero(1, "1"))
    end)

    it("should return false for number and boolean", function()
      assert.is_false(g.same.value_zero(1, true))
    end)

    it("should return true for equal booleans", function()
      assert.is_true(g.same.value_zero(true, true))
      assert.is_true(g.same.value_zero(false, false))
    end)

    it("should return false for different booleans", function()
      assert.is_false(g.same.value_zero(true, false))
    end)

    it("should return true for same table reference", function()
      local t = {1, 2, 3}
      assert.is_true(g.same.value_zero(t, t))
    end)

    it("should return false for different tables with same content", function()
      assert.is_false(g.same.value_zero({1, 2}, {1, 2}))
    end)

    it("should return true for same function reference", function()
      local f = function() end
      assert.is_true(g.same.value_zero(f, f))
    end)

    it("should return false for different functions", function()
      assert.is_false(g.same.value_zero(function() end, function() end))
    end)
  end)

  -- ========================================================================
  -- value (NaN same, +0/-0 different)
  -- ========================================================================

  describe("value", function()
    it("should return true for equal numbers", function()
      assert.is_true(g.same.value(42, 42))
    end)

    it("should return false for different numbers", function()
      assert.is_false(g.same.value(1, 2))
    end)

    it("should return true for equal strings", function()
      assert.is_true(g.same.value("hello", "hello"))
    end)

    it("should return false for different strings", function()
      assert.is_false(g.same.value("hello", "world"))
    end)

    it("should return true for both NaN", function()
      assert.is_true(g.same.value(0/0, 0/0))
    end)

    it("should return false for NaN and number", function()
      assert.is_false(g.same.value(0/0, 1))
    end)

    it("should treat +0 and -0 as the same", function()
      assert.is_true(g.same.value(0, -0))
    end)

    it("should return true for +0 and +0", function()
      assert.is_true(g.same.value(0, 0))
    end)

    it("should return false for different types", function()
      assert.is_false(g.same.value(1, "1"))
    end)

    it("should return false for number and boolean", function()
      assert.is_false(g.same.value(1, true))
    end)

    it("should return true for equal booleans", function()
      assert.is_true(g.same.value(true, true))
      assert.is_true(g.same.value(false, false))
    end)

    it("should return false for different booleans", function()
      assert.is_false(g.same.value(true, false))
    end)

    it("should return true for same table reference", function()
      local t = {1, 2, 3}
      assert.is_true(g.same.value(t, t))
    end)

    it("should return false for different tables with same content", function()
      assert.is_false(g.same.value({1, 2}, {1, 2}))
    end)
  end)
end)
