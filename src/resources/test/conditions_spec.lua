describe("conditions module", function()
  local g

  setup(function()
    g = Glu("Glu")
  end)

  -- ========================================================================
  -- is
  -- ========================================================================

  describe("is", function()
    it("should return true and nil for true condition", function()
      local result, message = g.conditions.is(true)
      assert.is_true(result)
      assert.is_nil(message)
    end)

    it("should return false and message for false condition", function()
      local result, message = g.conditions.is(false, "something went wrong")
      assert.is_false(result)
      assert.are.equal("something went wrong", message)
    end)

    it("should return false and nil message when no message provided", function()
      local result, message = g.conditions.is(false)
      assert.is_false(result)
      assert.is_nil(message)
    end)

    it("should error on non-boolean condition", function()
      assert.has_error(function()
        g.conditions.is("true")
      end)
    end)

    it("should error on nil condition", function()
      assert.has_error(function()
        g.conditions.is(nil)
      end)
    end)

    it("should error on number condition", function()
      assert.has_error(function()
        g.conditions.is(1)
      end)
    end)

    it("should error on non-string message", function()
      assert.has_error(function()
        g.conditions.is(true, 42)
      end)
    end)
  end)

  -- ========================================================================
  -- is_true
  -- ========================================================================

  describe("is_true", function()
    it("should return true for true condition", function()
      local result, message = g.conditions.is_true(true)
      assert.is_true(result)
      assert.is_nil(message)
    end)

    it("should return false with default message for false condition", function()
      local result, message = g.conditions.is_true(false)
      assert.is_false(result)
      assert.are.equal("Expected condition to be true", message)
    end)

    it("should return false with custom message for false condition", function()
      local result, message = g.conditions.is_true(false, "custom fail")
      assert.is_false(result)
      assert.are.equal("custom fail", message)
    end)
  end)

  -- ========================================================================
  -- is_false
  -- ========================================================================

  describe("is_false", function()
    it("should return true for false condition", function()
      local result, message = g.conditions.is_false(false)
      assert.is_true(result)
      assert.is_nil(message)
    end)

    it("should return false with default message for true condition", function()
      local result, message = g.conditions.is_false(true)
      assert.is_false(result)
      assert.are.equal("Expected condition to be false", message)
    end)

    it("should return false with custom message for true condition", function()
      local result, message = g.conditions.is_false(true, "custom fail")
      assert.is_false(result)
      assert.are.equal("custom fail", message)
    end)
  end)

  -- ========================================================================
  -- is_nil
  -- ========================================================================

  describe("is_nil", function()
    it("should return true for nil value", function()
      local result, message = g.conditions.is_nil(nil)
      assert.is_true(result)
      assert.is_nil(message)
    end)

    it("should return false for non-nil value", function()
      local result, message = g.conditions.is_nil(42)
      assert.is_false(result)
      assert.is_truthy(message)
    end)

    it("should return false for false value (not nil)", function()
      local result, message = g.conditions.is_nil(false)
      assert.is_false(result)
      assert.is_truthy(message)
    end)

    it("should return false with custom message", function()
      local result, message = g.conditions.is_nil("hello", "should be nil")
      assert.is_false(result)
      assert.are.equal("should be nil", message)
    end)
  end)

  -- ========================================================================
  -- is_not_nil
  -- ========================================================================

  describe("is_not_nil", function()
    it("should return true for non-nil value", function()
      local result, message = g.conditions.is_not_nil(42)
      assert.is_true(result)
      assert.is_nil(message)
    end)

    it("should return true for false value (not nil)", function()
      local result, message = g.conditions.is_not_nil(false)
      assert.is_true(result)
      assert.is_nil(message)
    end)

    it("should return false for nil value", function()
      local result, message = g.conditions.is_not_nil(nil)
      assert.is_false(result)
      assert.is_truthy(message)
    end)

    it("should return false with custom message", function()
      local result, message = g.conditions.is_not_nil(nil, "should exist")
      assert.is_false(result)
      assert.are.equal("should exist", message)
    end)
  end)

  -- ========================================================================
  -- is_error
  -- ========================================================================

  describe("is_error", function()
    it("should return true when function throws", function()
      local result, message = g.conditions.is_error(function()
        error("boom")
      end)
      assert.is_true(result)
      assert.is_nil(message)
    end)

    it("should return false when function does not throw", function()
      local result, message = g.conditions.is_error(function()
        return 42
      end)
      assert.is_false(result)
      assert.is_truthy(message)
    end)

    it("should return false with custom message when function does not throw", function()
      local result, message = g.conditions.is_error(function()
        return 42
      end, "expected an error")
      assert.is_false(result)
      assert.are.equal("expected an error", message)
    end)

    it("should pass error to check function", function()
      local captured_err
      local result = g.conditions.is_error(function()
        error("specific error")
      end, nil, function(err)
        captured_err = err
        return true
      end)
      assert.is_true(result)
      assert.is_truthy(captured_err)
    end)

    it("should return false when check function returns false", function()
      local result, message = g.conditions.is_error(function()
        error("wrong error")
      end, nil, function(err)
        return false
      end)
      assert.is_false(result)
      assert.is_truthy(message)
    end)

    it("should return false when check function itself errors", function()
      local result, message = g.conditions.is_error(function()
        error("original")
      end, nil, function(err)
        error("checker broke")
      end)
      assert.is_false(result)
      assert.is_truthy(message)
    end)

    it("should error on non-function first argument", function()
      assert.has_error(function()
        g.conditions.is_error("not a function")
      end)
    end)

    it("should error on non-string, non-nil message", function()
      assert.has_error(function()
        g.conditions.is_error(function() error("x") end, 42)
      end)
    end)

    it("should error on non-function, non-nil check", function()
      assert.has_error(function()
        g.conditions.is_error(function() error("x") end, nil, "not a function")
      end)
    end)
  end)

  -- ========================================================================
  -- is_eq
  -- ========================================================================

  describe("is_eq", function()
    it("should return true for equal numbers", function()
      local result, message = g.conditions.is_eq(42, 42)
      assert.is_true(result)
      assert.is_nil(message)
    end)

    it("should return true for equal strings", function()
      local result, message = g.conditions.is_eq("hello", "hello")
      assert.is_true(result)
      assert.is_nil(message)
    end)

    it("should return false for different values", function()
      local result, message = g.conditions.is_eq(1, 2)
      assert.is_false(result)
      assert.is_truthy(message)
    end)

    it("should return false for different types", function()
      local result, message = g.conditions.is_eq(1, "1")
      assert.is_false(result)
      assert.is_truthy(message)
    end)

    it("should return true for same table reference", function()
      local t = {1, 2, 3}
      local result = g.conditions.is_eq(t, t)
      assert.is_true(result)
    end)

    it("should return false for different tables with same content", function()
      local result = g.conditions.is_eq({1, 2}, {1, 2})
      assert.is_false(result)
    end)

    it("should return true for nil == nil", function()
      local result = g.conditions.is_eq(nil, nil)
      assert.is_true(result)
    end)

    it("should return false with custom message", function()
      local result, message = g.conditions.is_eq(1, 2, "not equal")
      assert.is_false(result)
      assert.are.equal("not equal", message)
    end)
  end)

  -- ========================================================================
  -- is_ne
  -- ========================================================================

  describe("is_ne", function()
    it("should return true for different values", function()
      local result, message = g.conditions.is_ne(1, 2)
      assert.is_true(result)
      assert.is_nil(message)
    end)

    it("should return false for equal values", function()
      local result, message = g.conditions.is_ne(42, 42)
      assert.is_false(result)
      assert.is_truthy(message)
    end)

    it("should return true for different types with same representation", function()
      local result = g.conditions.is_ne(1, "1")
      assert.is_true(result)
    end)

    it("should return false with custom message", function()
      local result, message = g.conditions.is_ne(5, 5, "should differ")
      assert.is_false(result)
      assert.are.equal("should differ", message)
    end)
  end)

  -- ========================================================================
  -- is_lt
  -- ========================================================================

  describe("is_lt", function()
    it("should return true when a < b", function()
      local result = g.conditions.is_lt(1, 2)
      assert.is_true(result)
    end)

    it("should return false when a == b", function()
      local result = g.conditions.is_lt(2, 2)
      assert.is_false(result)
    end)

    it("should return false when a > b", function()
      local result = g.conditions.is_lt(3, 2)
      assert.is_false(result)
    end)

    it("should work with strings (lexicographic)", function()
      local result = g.conditions.is_lt("a", "b")
      assert.is_true(result)
    end)

    it("should return false with custom message", function()
      local result, message = g.conditions.is_lt(5, 3, "not less")
      assert.is_false(result)
      assert.are.equal("not less", message)
    end)
  end)

  -- ========================================================================
  -- is_le
  -- ========================================================================

  describe("is_le", function()
    it("should return true when a < b", function()
      local result = g.conditions.is_le(1, 2)
      assert.is_true(result)
    end)

    it("should return true when a == b", function()
      local result = g.conditions.is_le(2, 2)
      assert.is_true(result)
    end)

    it("should return false when a > b", function()
      local result = g.conditions.is_le(3, 2)
      assert.is_false(result)
    end)
  end)

  -- ========================================================================
  -- is_gt
  -- ========================================================================

  describe("is_gt", function()
    it("should return true when a > b", function()
      local result = g.conditions.is_gt(3, 2)
      assert.is_true(result)
    end)

    it("should return false when a == b", function()
      local result = g.conditions.is_gt(2, 2)
      assert.is_false(result)
    end)

    it("should return false when a < b", function()
      local result = g.conditions.is_gt(1, 2)
      assert.is_false(result)
    end)
  end)

  -- ========================================================================
  -- is_ge
  -- ========================================================================

  describe("is_ge", function()
    it("should return true when a > b", function()
      local result = g.conditions.is_ge(3, 2)
      assert.is_true(result)
    end)

    it("should return true when a == b", function()
      local result = g.conditions.is_ge(2, 2)
      assert.is_true(result)
    end)

    it("should return false when a < b", function()
      local result = g.conditions.is_ge(1, 2)
      assert.is_false(result)
    end)

    it("should return false with custom message", function()
      local result, message = g.conditions.is_ge(1, 5, "too small")
      assert.is_false(result)
      assert.are.equal("too small", message)
    end)
  end)

  -- ========================================================================
  -- is_type
  -- ========================================================================

  describe("is_type", function()
    it("should return true for string type", function()
      local result = g.conditions.is_type("hello", "string")
      assert.is_true(result)
    end)

    it("should return true for number type", function()
      local result = g.conditions.is_type(42, "number")
      assert.is_true(result)
    end)

    it("should return true for table type", function()
      local result = g.conditions.is_type({}, "table")
      assert.is_true(result)
    end)

    it("should return true for boolean type", function()
      local result = g.conditions.is_type(true, "boolean")
      assert.is_true(result)
    end)

    it("should return true for function type", function()
      local result = g.conditions.is_type(function() end, "function")
      assert.is_true(result)
    end)

    it("should return true for nil type", function()
      local result = g.conditions.is_type(nil, "nil")
      assert.is_true(result)
    end)

    it("should return false for wrong type", function()
      local result, message = g.conditions.is_type(42, "string")
      assert.is_false(result)
      assert.is_truthy(message)
    end)

    it("should return false with custom message", function()
      local result, message = g.conditions.is_type(42, "string", "wrong type")
      assert.is_false(result)
      assert.are.equal("wrong type", message)
    end)
  end)

  -- ========================================================================
  -- is_deeply
  -- ========================================================================

  describe("is_deeply", function()
    it("should return true for equal flat tables", function()
      local result = g.conditions.is_deeply({1, 2, 3}, {1, 2, 3})
      assert.is_true(result)
    end)

    it("should return true for equal nested tables", function()
      local result = g.conditions.is_deeply(
        {a = {b = {c = 1}}},
        {a = {b = {c = 1}}}
      )
      assert.is_true(result)
    end)

    it("should return false for different nested values", function()
      local result = g.conditions.is_deeply(
        {a = {b = 1}},
        {a = {b = 2}}
      )
      assert.is_false(result)
    end)

    it("should return false when key missing in second", function()
      local result, message = g.conditions.is_deeply(
        {a = 1, b = 2},
        {a = 1}
      )
      assert.is_false(result)
      assert.is_truthy(message)
    end)

    it("should return false when extra key in second", function()
      local result, message = g.conditions.is_deeply(
        {a = 1},
        {a = 1, b = 2}
      )
      assert.is_false(result)
      assert.is_truthy(message)
    end)

    it("should return true for empty tables", function()
      local result = g.conditions.is_deeply({}, {})
      assert.is_true(result)
    end)

    it("should return true for equal non-table scalars", function()
      local result = g.conditions.is_deeply(42, 42)
      assert.is_true(result)
    end)

    it("should return false for different non-table scalars", function()
      local result = g.conditions.is_deeply(42, 43)
      assert.is_false(result)
    end)

    it("should return true for same table reference", function()
      local t = {1, 2, 3}
      local result = g.conditions.is_deeply(t, t)
      assert.is_true(result)
    end)

    it("should handle mixed key types", function()
      local result = g.conditions.is_deeply(
        {[1] = "a", ["x"] = "b"},
        {[1] = "a", ["x"] = "b"}
      )
      assert.is_true(result)
    end)

    it("should return false with custom message", function()
      local result, message = g.conditions.is_deeply({1}, {2}, "tables differ")
      assert.is_false(result)
      assert.are.equal("tables differ", message)
    end)
  end)
end)
