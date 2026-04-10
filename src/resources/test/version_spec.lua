describe("version module", function()
  local g

  setup(function()
    g = Glu("Glu")
  end)

  -- ========================================================================
  -- compare
  -- ========================================================================

  describe("compare", function()
    it("should return 0 for equal versions", function()
      assert.are.equal(0, g.version.compare("1.0.0", "1.0.0"))
    end)

    it("should return 1 when first is greater (major)", function()
      assert.are.equal(1, g.version.compare("2.0.0", "1.0.0"))
    end)

    it("should return -1 when first is lesser (major)", function()
      assert.are.equal(-1, g.version.compare("1.0.0", "2.0.0"))
    end)

    it("should compare minor versions", function()
      assert.are.equal(1, g.version.compare("1.2.0", "1.1.0"))
      assert.are.equal(-1, g.version.compare("1.1.0", "1.2.0"))
    end)

    it("should compare patch versions", function()
      assert.are.equal(1, g.version.compare("1.0.2", "1.0.1"))
      assert.are.equal(-1, g.version.compare("1.0.1", "1.0.2"))
    end)

    it("should return 0 for equal two-segment versions", function()
      assert.are.equal(0, g.version.compare("1.0", "1.0"))
    end)

    it("should compare two-segment versions", function()
      assert.are.equal(1, g.version.compare("2.1", "2.0"))
      assert.are.equal(-1, g.version.compare("2.0", "2.1"))
    end)

    it("should return 0 for equal single-segment versions", function()
      assert.are.equal(0, g.version.compare("5", "5"))
    end)

    it("should compare single-segment versions", function()
      assert.are.equal(1, g.version.compare("5", "3"))
      assert.are.equal(-1, g.version.compare("3", "5"))
    end)

    it("should accept number inputs", function()
      assert.are.equal(0, g.version.compare(1, 1))
      assert.are.equal(1, g.version.compare(2, 1))
      assert.are.equal(-1, g.version.compare(1, 2))
    end)

    it("should correctly compare numeric segments >= 10", function()
      assert.are.equal(-1, g.version.compare("1.9.0", "1.10.0"))
      assert.are.equal(1, g.version.compare("1.10.0", "1.9.0"))
    end)

    it("should compare string segments lexicographically", function()
      assert.are.equal(-1, g.version.compare("1.0.alpha", "1.0.beta"))
      assert.are.equal(1, g.version.compare("1.0.beta", "1.0.alpha"))
    end)

    it("should error when segment counts differ", function()
      assert.has_error(function()
        g.version.compare("1.0.0", "1.0")
      end)
    end)

    it("should error on mixed types", function()
      assert.has_error(function()
        g.version.compare("1.0.0", 1)
      end)
    end)

    it("should error on boolean input", function()
      assert.has_error(function()
        g.version.compare(true, false)
      end)
    end)

    it("should error on table input", function()
      assert.has_error(function()
        g.version.compare({1, 0}, {2, 0})
      end)
    end)

    it("should error on nil input", function()
      assert.has_error(function()
        g.version.compare(nil, "1.0.0")
      end)
    end)
  end)
end)
