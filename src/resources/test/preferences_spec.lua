describe("preferences module", function()
  local g
  local test_pkg = "GluTestPrefs"
  local test_file = "test_prefs.lua"
  local test_dir

  setup(function()
    g = Glu("Glu")
    test_dir = getMudletHomeDir() .. "/" .. test_pkg
    lfs.mkdir(test_dir)
  end)

  teardown(function()
    -- Cleanup
    pcall(os.remove, test_dir .. "/" .. test_file)
    pcall(lfs.rmdir, test_dir)
  end)

  -- ========================================================================
  -- save
  -- ========================================================================

  describe("save", function()
    it("should save preferences to a file with package", function()
      assert.has_no.errors(function()
        g.preferences.save(test_pkg, test_file, {key = "value"})
      end)
      assert.is_true(io.exists(test_dir .. "/" .. test_file))
    end)

    it("should save preferences without package", function()
      local file = "glu_test_no_pkg.lua"
      local path = getMudletHomeDir() .. "/" .. file
      assert.has_no.errors(function()
        g.preferences.save(nil, file, {x = 1})
      end)
      assert.is_true(io.exists(path))
      -- Cleanup
      os.remove(path)
    end)

    it("should error on non-string package (non-nil)", function()
      assert.has_error(function()
        g.preferences.save(123, test_file, {})
      end)
    end)

    it("should error on non-string file", function()
      assert.has_error(function()
        g.preferences.save(test_pkg, 123, {})
      end)
    end)

    it("should error on non-table prefs", function()
      assert.has_error(function()
        g.preferences.save(test_pkg, test_file, "not a table")
      end)
    end)
  end)

  -- ========================================================================
  -- load
  -- ========================================================================

  describe("load", function()
    it("should load saved preferences", function()
      g.preferences.save(test_pkg, test_file, {saved_key = "saved_value"})
      local result = g.preferences.load(test_pkg, test_file, {})
      assert.are.equal("saved_value", result.saved_key)
    end)

    it("should return defaults when file does not exist", function()
      local defaults = {fallback = true, count = 42}
      local result = g.preferences.load(test_pkg, "nonexistent.lua", defaults)
      assert.are.same(defaults, result)
    end)

    it("should merge saved prefs with defaults", function()
      g.preferences.save(test_pkg, test_file, {existing = "yes"})
      local defaults = {existing = "no", missing = "default"}
      local result = g.preferences.load(test_pkg, test_file, defaults)
      assert.are.equal("yes", result.existing)
      assert.are.equal("default", result.missing)
    end)

    it("should load without package", function()
      local file = "glu_test_load_no_pkg.lua"
      g.preferences.save(nil, file, {data = 99})
      local result = g.preferences.load(nil, file, {})
      assert.are.equal(99, result.data)
      -- Cleanup
      os.remove(getMudletHomeDir() .. "/" .. file)
    end)

    it("should error on non-string package (non-nil)", function()
      assert.has_error(function()
        g.preferences.load(123, test_file, {})
      end)
    end)

    it("should error on non-string file", function()
      assert.has_error(function()
        g.preferences.load(test_pkg, 123, {})
      end)
    end)

    it("should error on non-table defaults", function()
      assert.has_error(function()
        g.preferences.load(test_pkg, test_file, "not a table")
      end)
    end)
  end)
end)
