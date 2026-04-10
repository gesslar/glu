describe("glass_loader module", function()
  local g
  local fixtures_dir

  setup(function()
    g = Glu("Glu")
    fixtures_dir = getMudletHomeDir() .. "/Glu/test/fixtures"
  end)

  -- ========================================================================
  -- load_glass — local file
  -- ========================================================================

  describe("load_glass from file", function()
    it("should load and return a function from a valid lua file", function()
      -- Create a temp lua file
      local tmp = g.fd.temp_dir()
      local path = tmp .. "/test_glass.lua"
      g.fd.write_file(path, 'return "loaded"', true)

      local result, err
      g.glass_loader.load_glass({
        path = path,
        cb = function(r, e) result = r; err = e end
      })

      assert.is_truthy(result)
      assert.is_nil(err)
      assert.are.equal("function", type(result))

      -- Cleanup
      os.remove(path)
      lfs.rmdir(tmp)
    end)

    it("should execute the loaded code when execute=true", function()
      local tmp = g.fd.temp_dir()
      local path = tmp .. "/exec_glass.lua"
      g.fd.write_file(path, '_G._glass_loader_test = true', true)

      g.glass_loader.load_glass({
        path = path,
        execute = true,
        cb = function() end
      })

      assert.is_true(_G._glass_loader_test)
      _G._glass_loader_test = nil

      -- Cleanup
      os.remove(path)
      lfs.rmdir(tmp)
    end)

    it("should call cb with nil and error for non-existing file", function()
      local result, err
      g.glass_loader.load_glass({
        path = "/nonexistent/file.lua",
        cb = function(r, e) result = r; err = e end
      })

      assert.is_nil(result)
      assert.is_truthy(err)
    end)

    it("should call cb with nil and error for invalid lua syntax", function()
      local tmp = g.fd.temp_dir()
      local path = tmp .. "/bad_glass.lua"
      g.fd.write_file(path, 'this is not valid lua {{{{', true)

      local result, err
      g.glass_loader.load_glass({
        path = path,
        cb = function(r, e) result = r; err = e end
      })

      assert.is_nil(result)
      assert.is_truthy(err)

      -- Cleanup
      os.remove(path)
      lfs.rmdir(tmp)
    end)
  end)

  -- ========================================================================
  -- load_glass — validation
  -- ========================================================================

  describe("load_glass validation", function()
    it("should return false when callback is missing", function()
      local ok, err = g.glass_loader.load_glass({path = "/some/path"})
      assert.is_false(ok)
      assert.are.equal("callback is required", err)
    end)

    it("should call cb with error when path is missing", function()
      local result, err
      g.glass_loader.load_glass({
        cb = function(r, e) result = r; err = e end
      })

      assert.is_nil(result)
      assert.are.equal("No file or url provided", err)
    end)
  end)

  -- ========================================================================
  -- load_glass — execute error handling
  -- ========================================================================

  describe("load_glass execute errors", function()
    it("should call cb with error when execution fails", function()
      local tmp = g.fd.temp_dir()
      local path = tmp .. "/error_glass.lua"
      g.fd.write_file(path, 'error("intentional error")', true)

      local result, err
      g.glass_loader.load_glass({
        path = path,
        execute = true,
        cb = function(r, e) result = r; err = e end
      })

      assert.is_nil(result)
      assert.is_truthy(err)

      -- Cleanup
      os.remove(path)
      lfs.rmdir(tmp)
    end)
  end)
end)
