describe("number module", function()
  local g

  setup(function()
    g = Glu("Glu")
  end)

  -- ========================================================================
  -- Rounding
  -- ========================================================================

  describe("round", function()
    it("should round to nearest integer by default", function()
      assert.are.equal(3, g.number.round(3.14159))
    end)

    it("should round to specified decimal places", function()
      assert.are.equal(3.14, g.number.round(3.14159, 2))
    end)

    it("should round up when appropriate", function()
      assert.are.equal(4, g.number.round(3.5))
    end)

    it("should round negative numbers", function()
      assert.are.equal(-3, g.number.round(-3.4))
    end)

    it("should handle zero", function()
      assert.are.equal(0, g.number.round(0))
    end)

    it("should error on non-number", function()
      assert.has_error(function()
        g.number.round("hello")
      end)
    end)
  end)

  -- ========================================================================
  -- Clamping
  -- ========================================================================

  describe("clamp", function()
    it("should return the number when within range", function()
      assert.are.equal(10, g.number.clamp(10, 1, 100))
    end)

    it("should return min when below range", function()
      assert.are.equal(1, g.number.clamp(-5, 1, 100))
    end)

    it("should return max when above range", function()
      assert.are.equal(100, g.number.clamp(200, 1, 100))
    end)

    it("should return boundary values", function()
      assert.are.equal(1, g.number.clamp(1, 1, 100))
      assert.are.equal(100, g.number.clamp(100, 1, 100))
    end)
  end)

  -- ========================================================================
  -- Interpolation
  -- ========================================================================

  describe("lerp", function()
    it("should return start at t=0", function()
      assert.are.equal(0, g.number.lerp(0, 100, 0))
    end)

    it("should return end at t=1", function()
      assert.are.equal(100, g.number.lerp(0, 100, 1))
    end)

    it("should return midpoint at t=0.5", function()
      assert.are.equal(50, g.number.lerp(0, 100, 0.5))
    end)

    it("should work with negative ranges", function()
      assert.are.equal(-50, g.number.lerp(-100, 0, 0.5))
    end)

    it("should error when t is out of range", function()
      assert.has_error(function()
        g.number.lerp(0, 100, 1.5)
      end)
    end)
  end)

  describe("lerp_smooth", function()
    it("should return start at t=0", function()
      assert.are.equal(0, g.number.lerp_smooth(0, 100, 0))
    end)

    it("should return end at t=1", function()
      assert.are.equal(100, g.number.lerp_smooth(0, 100, 1))
    end)

    it("should return midpoint at t=0.5", function()
      assert.are.equal(50, g.number.lerp_smooth(0, 100, 0.5))
    end)

    it("should produce a value between start and end", function()
      local result = g.number.lerp_smooth(0, 100, 0.25)
      assert.is_true(result > 0 and result < 50)
    end)

    it("should error when t is out of range", function()
      assert.has_error(function()
        g.number.lerp_smooth(0, 100, -0.1)
      end)
    end)
  end)

  describe("lerp_smoother", function()
    it("should return start at t=0", function()
      assert.are.equal(0, g.number.lerp_smoother(0, 100, 0))
    end)

    it("should return end at t=1", function()
      assert.are.equal(100, g.number.lerp_smoother(0, 100, 1))
    end)

    it("should return midpoint at t=0.5", function()
      assert.are.equal(50, g.number.lerp_smoother(0, 100, 0.5))
    end)

    it("should produce a value between start and end", function()
      local result = g.number.lerp_smoother(0, 100, 0.25)
      assert.is_true(result > 0 and result < 50)
    end)
  end)

  describe("lerp_ease_in", function()
    it("should return start at t=0", function()
      assert.are.equal(0, g.number.lerp_ease_in(0, 100, 0))
    end)

    it("should return end at t=1", function()
      assert.are.equal(100, g.number.lerp_ease_in(0, 100, 1))
    end)

    it("should ease in slowly at first", function()
      -- Quadratic ease in: at t=0.5, result should be 25 (0.5^2 * 100)
      assert.are.equal(25, g.number.lerp_ease_in(0, 100, 0.5))
    end)

    it("should be less than linear at midpoint", function()
      local ease = g.number.lerp_ease_in(0, 100, 0.5)
      local linear = g.number.lerp(0, 100, 0.5)
      assert.is_true(ease < linear)
    end)
  end)

  describe("lerp_ease_out", function()
    it("should return start at t=0", function()
      assert.are.equal(0, g.number.lerp_ease_out(0, 100, 0))
    end)

    it("should return end at t=1", function()
      assert.are.equal(100, g.number.lerp_ease_out(0, 100, 1))
    end)

    it("should ease out slowly at end", function()
      -- Quadratic ease out: at t=0.5, result should be 75 (0.5*(2-0.5) * 100)
      assert.are.equal(75, g.number.lerp_ease_out(0, 100, 0.5))
    end)

    it("should be greater than linear at midpoint", function()
      local ease = g.number.lerp_ease_out(0, 100, 0.5)
      local linear = g.number.lerp(0, 100, 0.5)
      assert.is_true(ease > linear)
    end)
  end)

  -- ========================================================================
  -- Mapping
  -- ========================================================================

  describe("map", function()
    it("should map a value from one range to another", function()
      assert.are.equal(50, g.number.map(5, 0, 10, 0, 100))
    end)

    it("should handle inverted ranges", function()
      assert.are.equal(50, g.number.map(5, 0, 10, 100, 0))
    end)

    it("should handle negative ranges", function()
      assert.are.equal(0, g.number.map(5, 0, 10, -50, 50))
    end)

    it("should map boundary values", function()
      assert.are.equal(0, g.number.map(0, 0, 10, 0, 100))
      assert.are.equal(100, g.number.map(10, 0, 10, 0, 100))
    end)
  end)

  -- ========================================================================
  -- Checks
  -- ========================================================================

  describe("positive", function()
    it("should return true for positive numbers", function()
      assert.is_true(g.number.positive(10))
    end)

    it("should return false for negative numbers", function()
      assert.is_false(g.number.positive(-10))
    end)

    it("should return false for zero", function()
      assert.is_false(g.number.positive(0))
    end)
  end)

  describe("is_between", function()
    it("should return true when number is in range", function()
      assert.is_true(g.number.is_between(5, 1, 10))
    end)

    it("should return true for boundary values", function()
      assert.is_true(g.number.is_between(1, 1, 10))
      assert.is_true(g.number.is_between(10, 1, 10))
    end)

    it("should return false when out of range", function()
      assert.is_false(g.number.is_between(11, 1, 10))
      assert.is_false(g.number.is_between(0, 1, 10))
    end)
  end)

  describe("sign", function()
    it("should return 1 for positive", function()
      assert.are.equal(1, g.number.sign(42))
    end)

    it("should return -1 for negative", function()
      assert.are.equal(-1, g.number.sign(-42))
    end)

    it("should return 0 for zero", function()
      assert.are.equal(0, g.number.sign(0))
    end)
  end)

  describe("is_approximate", function()
    it("should return true for values within tolerance", function()
      assert.is_true(g.number.is_approximate(100, 104, 5))
    end)

    it("should return false for values outside tolerance", function()
      assert.is_false(g.number.is_approximate(100, 106, 5))
    end)

    it("should default to 5% tolerance", function()
      assert.is_true(g.number.is_approximate(100, 105))
      assert.is_false(g.number.is_approximate(100, 106))
    end)

    it("should handle zero base value", function()
      -- 5% of 0 is 0, so only 0 is approximately equal to 0
      assert.is_true(g.number.is_approximate(0, 0))
      assert.is_false(g.number.is_approximate(0, 1))
    end)
  end)

  -- ========================================================================
  -- Aggregation (min, max, sum)
  -- ========================================================================

  describe("min", function()
    it("should return minimum of varargs", function()
      assert.are.equal(1, g.number.min(3, 1, 2))
    end)

    it("should return minimum of a table", function()
      assert.are.equal(1, g.number.min({3, 1, 2}))
    end)

    it("should handle single value", function()
      assert.are.equal(5, g.number.min(5))
    end)

    it("should handle negative numbers", function()
      assert.are.equal(-10, g.number.min(-10, -5, 0, 5))
    end)
  end)

  describe("max", function()
    it("should return maximum of varargs", function()
      assert.are.equal(3, g.number.max(3, 1, 2))
    end)

    it("should return maximum of a table", function()
      assert.are.equal(3, g.number.max({3, 1, 2}))
    end)

    it("should handle single value", function()
      assert.are.equal(5, g.number.max(5))
    end)

    it("should handle negative numbers", function()
      assert.are.equal(5, g.number.max(-10, -5, 0, 5))
    end)
  end)

  describe("sum", function()
    it("should sum varargs", function()
      assert.are.equal(6, g.number.sum(1, 2, 3))
    end)

    it("should sum a table", function()
      assert.are.equal(6, g.number.sum({1, 2, 3}))
    end)

    it("should handle single value", function()
      assert.are.equal(5, g.number.sum(5))
    end)

    it("should handle negative numbers", function()
      assert.are.equal(-3, g.number.sum(-1, -2, 0))
    end)

    it("should handle floats", function()
      local result = g.number.sum(1.1, 2.2)
      assert.is_true(g.number.is_approximate(result, 3.3, 1))
    end)
  end)

  -- ========================================================================
  -- Random
  -- ========================================================================

  describe("random_clamp", function()
    it("should return a value within range", function()
      local result = g.number.random_clamp(10, 20)
      assert.is_true(result >= 10 and result <= 20)
    end)

    it("should handle negative range", function()
      local result = g.number.random_clamp(-100, -50)
      assert.is_true(result >= -100 and result <= -50)
    end)

    it("should return min when min equals max", function()
      local result = g.number.random_clamp(5, 5)
      assert.are.equal(5, result)
    end)
  end)

  -- ========================================================================
  -- Average / Mean
  -- ========================================================================

  describe("average", function()
    it("should calculate average of varargs", function()
      assert.are.equal(2, g.number.average(1, 2, 3))
    end)

    it("should calculate average of a table", function()
      assert.are.equal(2, g.number.average({1, 2, 3}))
    end)

    it("should handle single-element table", function()
      assert.are.equal(5, g.number.average({5}))
    end)

    it("should handle decimal results", function()
      assert.are.equal(2.5, g.number.average(2, 3))
    end)
  end)

  describe("mean", function()
    it("should calculate mean of varargs", function()
      assert.are.equal(2, g.number.mean(1, 2, 3))
    end)

    it("should calculate mean of a table", function()
      assert.are.equal(2, g.number.mean({1, 2, 3}))
    end)

    it("should produce same result as average", function()
      assert.are.equal(
        g.number.average(10, 20, 30),
        g.number.mean(10, 20, 30)
      )
    end)
  end)

  -- ========================================================================
  -- Percentage calculations
  -- ========================================================================

  describe("percent_of", function()
    it("should calculate what percentage one number is of another", function()
      assert.are.equal(50, g.number.percent_of(50, 100))
    end)

    it("should round when specified", function()
      assert.are.equal(33.33, g.number.percent_of(1, 3, 2))
    end)

    it("should handle values greater than 100%", function()
      assert.are.equal(200, g.number.percent_of(200, 100))
    end)
  end)

  describe("percent", function()
    it("should calculate percentage of a total", function()
      assert.are.equal(25, g.number.percent(25, 100))
    end)

    it("should handle small percentages", function()
      assert.are.equal(1, g.number.percent(5, 20))
    end)

    it("should round when specified", function()
      assert.are.equal(33.33, g.number.percent(33.33, 100, 2))
    end)

    it("should handle 100%", function()
      assert.are.equal(50, g.number.percent(100, 50))
    end)

    it("should handle 0%", function()
      assert.are.equal(0, g.number.percent(0, 100))
    end)
  end)

  -- ========================================================================
  -- Normalize
  -- ========================================================================

  describe("normalize", function()
    it("should normalize to 0-1 range", function()
      assert.are.equal(0.5, g.number.normalize(50, 0, 100))
    end)

    it("should return 0 at min", function()
      assert.are.equal(0, g.number.normalize(0, 0, 100))
    end)

    it("should return 1 at max", function()
      assert.are.equal(1, g.number.normalize(100, 0, 100))
    end)

    it("should handle non-zero-based range", function()
      assert.are.equal(0.5, g.number.normalize(15, 10, 20))
    end)
  end)

  -- ========================================================================
  -- Constrain
  -- ========================================================================

  describe("constrain", function()
    it("should constrain to precision 0.01", function()
      assert.are.equal(3.14, g.number.constrain(3.14159, 0.01))
    end)

    it("should constrain to precision 0.1", function()
      assert.are.equal(3.1, g.number.constrain(3.14159, 0.1))
    end)

    it("should constrain to precision 1", function()
      assert.are.equal(3, g.number.constrain(3.14159, 1))
    end)

    it("should constrain to precision 5", function()
      assert.are.equal(5, g.number.constrain(3.14159, 5))
    end)

    it("should constrain to precision 10", function()
      assert.are.equal(50, g.number.constrain(47, 10))
    end)

    it("should handle exact multiples", function()
      assert.are.equal(10, g.number.constrain(10, 5))
    end)
  end)

  -- ========================================================================
  -- Validator
  -- ========================================================================

  describe("range validator", function()
    -- The range validator is used internally by other modules (e.g. n_add).
    -- We test it indirectly through table.n_add which uses ___.v.range.
    it("should accept value within range", function()
      assert.has_no.errors(function()
        local t = {1, 2, 3}
        g.table.n_add(t, {4}, 2)
      end)
    end)

    it("should reject value outside range", function()
      assert.has_error(function()
        local t = {1, 2, 3}
        g.table.n_add(t, {4}, 10)
      end)
    end)
  end)
end)
