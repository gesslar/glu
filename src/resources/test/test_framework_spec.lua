describe("test framework", function()
  local g

  setup(function()
    g = Glu("Glu")
  end)

  -- ========================================================================
  -- test.runner
  -- ========================================================================

  describe("test.runner", function()
    it("should create a runner", function()
      local runner = g.test.runner()
      assert.is_truthy(runner)
    end)

    it("should create a runner with an id", function()
      local runner = g.test.runner()
      assert.is_truthy(runner.id)
      assert.are.equal("string", type(runner.id))
    end)

    it("should have default colours", function()
      local runner = g.test.runner()
      assert.are.equal("<yellow_green>", runner.colours.pass)
      assert.are.equal("<orange_red>", runner.colours.fail)
    end)

    it("should have default symbols", function()
      local runner = g.test.runner()
      assert.is_truthy(runner.symbols.pass)
      assert.is_truthy(runner.symbols.fail)
    end)

    it("should accept custom colours", function()
      local runner = g.test.runner({
        colour = { pass = "<green>", fail = "<red>" }
      })
      assert.are.equal("<green>", runner.colours.pass)
      assert.are.equal("<red>", runner.colours.fail)
    end)

    it("should initialize with empty tests", function()
      local runner = g.test.runner()
      assert.are.same({}, runner.tests)
    end)
  end)

  -- ========================================================================
  -- test_runner.add / remove
  -- ========================================================================

  describe("test_runner.add", function()
    it("should add a test", function()
      local runner = g.test.runner()
      runner.add("my test", function() end)
      assert.are.equal(1, #runner.tests)
      assert.are.equal("my test", runner.tests[1].name)
    end)

    it("should return self for chaining", function()
      local runner = g.test.runner()
      local result = runner.add("test1", function() end)
      assert.are.equal(runner, result)
    end)

    it("should add multiple tests", function()
      local runner = g.test.runner()
      runner.add("test1", function() end)
            .add("test2", function() end)
      assert.are.equal(2, #runner.tests)
    end)

    it("should initialize test counters to 0", function()
      local runner = g.test.runner()
      runner.add("test1", function() end)
      assert.are.equal(0, runner.tests[1].passes)
      assert.are.equal(0, runner.tests[1].fails)
      assert.are.equal(0, runner.tests[1].total)
    end)

    it("should store runner reference in test", function()
      local runner = g.test.runner()
      runner.add("test1", function() end)
      assert.are.equal(runner, runner.tests[1].runner)
    end)

    it("should error on non-string name", function()
      local runner = g.test.runner()
      assert.has_error(function()
        runner.add(123, function() end)
      end)
    end)

    it("should error on non-function test", function()
      local runner = g.test.runner()
      assert.has_error(function()
        runner.add("test", "not a function")
      end)
    end)
  end)

  describe("test_runner.remove", function()
    it("should remove a test by name", function()
      local runner = g.test.runner()
      runner.add("test1", function() end)
            .add("test2", function() end)
      runner.remove("test1")
      assert.are.equal(1, #runner.tests)
      assert.are.equal("test2", runner.tests[1].name)
    end)

    it("should return self for chaining", function()
      local runner = g.test.runner()
      runner.add("test1", function() end)
      local result = runner.remove("test1")
      assert.are.equal(runner, result)
    end)

    it("should error on non-existing test", function()
      local runner = g.test.runner()
      assert.has_error(function()
        runner.remove("nonexistent")
      end)
    end)
  end)

  -- ========================================================================
  -- test_runner.reset / wipe
  -- ========================================================================

  describe("test_runner.reset", function()
    it("should reset counters to 0", function()
      local runner = g.test.runner()
      runner.add("test1", function() end)
      -- Manually set counters
      runner.tests[1].passes = 5
      runner.tests[1].fails = 3
      runner.tests[1].total = 8
      runner.reset()
      assert.are.equal(0, runner.tests[1].passes)
      assert.are.equal(0, runner.tests[1].fails)
      assert.are.equal(0, runner.tests[1].total)
    end)

    it("should return self for chaining", function()
      local runner = g.test.runner()
      local result = runner.reset()
      assert.are.equal(runner, result)
    end)
  end)

  describe("test_runner.wipe", function()
    it("should remove all tests", function()
      local runner = g.test.runner()
      runner.add("test1", function() end)
            .add("test2", function() end)
      runner.wipe()
      assert.are.equal(0, #runner.tests)
    end)

    it("should return self for chaining", function()
      local runner = g.test.runner()
      local result = runner.wipe()
      assert.are.equal(runner, result)
    end)
  end)

  -- ========================================================================
  -- test_runner.pass / fail
  -- ========================================================================

  describe("test_runner.pass / fail", function()
    it("should increment passes and total", function()
      local runner = g.test.runner()
      runner.add("test1", function() end)
      local test = runner.tests[1]
      runner.pass(test)
      assert.are.equal(1, test.passes)
      assert.are.equal(1, test.total)
      assert.are.equal(0, test.fails)
    end)

    it("should increment fails and total", function()
      local runner = g.test.runner()
      runner.add("test1", function() end)
      local test = runner.tests[1]
      runner.fail(test)
      assert.are.equal(0, test.passes)
      assert.are.equal(1, test.total)
      assert.are.equal(1, test.fails)
    end)
  end)

  -- ========================================================================
  -- Construction with initial tests
  -- ========================================================================

  describe("construction with tests", function()
    it("should accept tests via opts", function()
      local runner = g.test.runner({
        tests = {
          { name = "test1", func = function() end },
          { name = "test2", func = function() end }
        }
      })
      assert.are.equal(2, #runner.tests)
      assert.are.equal("test1", runner.tests[1].name)
      assert.are.equal("test2", runner.tests[2].name)
    end)

    it("should accept array-style test entries", function()
      local runner = g.test.runner({
        tests = {
          { "test1", function() end },
          { "test2", function() end }
        }
      })
      assert.are.equal(2, #runner.tests)
      assert.are.equal("test1", runner.tests[1].name)
    end)
  end)
end)
