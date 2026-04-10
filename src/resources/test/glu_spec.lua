describe("glu core framework", function()
  local g

  setup(function()
    g = Glu("Glu")
  end)

  -- ========================================================================
  -- Glu.new
  -- ========================================================================

  describe("Glu.new", function()
    it("should create an instance with package name", function()
      assert.is_truthy(g)
      assert.are.equal("Glu", g.package_name)
    end)

    it("should set the name to Glu", function()
      assert.are.equal("Glu", g.name)
    end)

    it("should be callable via Glu()", function()
      local g2 = Glu("Glu")
      assert.is_truthy(g2)
      assert.are.equal("Glu", g2.package_name)
    end)

    it("should error on non-string package name", function()
      assert.has_error(function()
        Glu.new(123)
      end)
    end)

    it("should error on non-string module_dir_name", function()
      assert.has_error(function()
        Glu.new("Glu", 123)
      end)
    end)

    it("should have TYPE constants", function()
      assert.are.equal("string", g.TYPE.STRING)
      assert.are.equal("number", g.TYPE.NUMBER)
      assert.are.equal("boolean", g.TYPE.BOOLEAN)
      assert.are.equal("table", g.TYPE.TABLE)
      assert.are.equal("function", g.TYPE.FUNCTION)
      assert.are.equal("nil", g.TYPE.NIL)
    end)

    it("should have TYPE constants in lowercase too", function()
      assert.are.equal("string", g.TYPE["string"])
      assert.are.equal("number", g.TYPE["number"])
      assert.are.equal("boolean", g.TYPE["boolean"])
    end)
  end)

  -- ========================================================================
  -- Glu.id
  -- ========================================================================

  describe("Glu.id", function()
    it("should return a string", function()
      assert.are.equal("string", type(Glu.id()))
    end)

    it("should return a UUID v4 format", function()
      local id = Glu.id()
      -- UUID v4: xxxxxxxx-xxxx-4xxx-[89ab]xxx-xxxxxxxxxxxx
      assert.is_truthy(rex.match(id, "^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"))
    end)

    it("should generate unique ids", function()
      local id1 = Glu.id()
      local id2 = Glu.id()
      assert.are_not.equal(id1, id2)
    end)

    it("should always have 4 as version digit", function()
      local id = Glu.id()
      local parts = id:split("-")
      assert.are.equal("4", parts[3]:sub(1, 1))
    end)
  end)

  -- ========================================================================
  -- Glu.get_glass / has_glass / get_glass_names
  -- ========================================================================

  describe("glass registry", function()
    it("should find a registered glass by name", function()
      local glass = Glu.get_glass("table")
      assert.is_truthy(glass)
      assert.are.equal("table", glass.name)
    end)

    it("should return nil for unregistered glass", function()
      assert.is_nil(Glu.get_glass("nonexistent_glass"))
    end)

    it("should report has_glass correctly for existing", function()
      assert.is_true(Glu.has_glass("table"))
      assert.is_true(Glu.has_glass("string"))
      assert.is_true(Glu.has_glass("number"))
    end)

    it("should report has_glass correctly for non-existing", function()
      assert.is_false(Glu.has_glass("nonexistent_glass"))
    end)

    it("should return list of registered glass names", function()
      local names = Glu.get_glass_names()
      assert.is_truthy(names)
      assert.is_true(#names > 0)
      assert.is_truthy(table.index_of(names, "table"))
      assert.is_truthy(table.index_of(names, "string"))
      assert.is_truthy(table.index_of(names, "number"))
    end)

    it("should return all glasses", function()
      local glasses = Glu.get_glasses()
      assert.is_truthy(glasses)
      assert.is_true(#glasses > 0)
    end)
  end)

  -- ========================================================================
  -- Instance module access
  -- ========================================================================

  describe("module access", function()
    it("should have table module", function()
      assert.is_truthy(g.table)
    end)

    it("should have string module", function()
      assert.is_truthy(g.string)
    end)

    it("should have number module", function()
      assert.is_truthy(g.number)
    end)

    it("should have colour module", function()
      assert.is_truthy(g.colour)
    end)

    it("should have fd module", function()
      assert.is_truthy(g.fd)
    end)

    it("should have http module", function()
      assert.is_truthy(g.http)
    end)
  end)

  -- ========================================================================
  -- has_object / get_object
  -- ========================================================================

  describe("has_object / get_object", function()
    it("should find existing module objects", function()
      assert.is_true(g.has_object("table"))
      assert.is_true(g.has_object("string"))
    end)

    it("should return false for non-existing objects", function()
      assert.is_false(g.has_object("nonexistent"))
    end)

    it("should return the object for existing", function()
      local obj = g.get_object("table")
      assert.is_truthy(obj)
    end)

    it("should return nil for non-existing objects", function()
      assert.is_nil(g.get_object("nonexistent"))
    end)
  end)

  -- ========================================================================
  -- getPackageName
  -- ========================================================================

  describe("getPackageName", function()
    it("should return the package name", function()
      assert.are.equal("Glu", g.getPackageName())
    end)
  end)

  -- ========================================================================
  -- Validators (v.type, v.test, v.not_nil, v.same_type)
  -- ========================================================================

  describe("validators", function()
    describe("v.type", function()
      it("should pass for correct type", function()
        assert.has_no.errors(function()
          g.v.type("hello", "string", 1, false)
        end)
      end)

      it("should error for wrong type", function()
        assert.has_error(function()
          g.v.type(123, "string", 1, false)
        end)
      end)

      it("should allow nil when nil_allowed is true", function()
        assert.has_no.errors(function()
          g.v.type(nil, "string", 1, true)
        end)
      end)

      it("should error on nil when nil_allowed is false", function()
        assert.has_error(function()
          g.v.type(nil, "string", 1, false)
        end)
      end)

      it("should accept any type", function()
        assert.has_no.errors(function()
          g.v.type("hello", "any", 1, false)
          g.v.type(123, "any", 1, false)
          g.v.type({}, "any", 1, false)
        end)
      end)

      it("should accept union types", function()
        assert.has_no.errors(function()
          g.v.type("hello", "string|number", 1, false)
          g.v.type(123, "string|number", 1, false)
        end)
      end)

      it("should error on union type mismatch", function()
        assert.has_error(function()
          g.v.type(true, "string|number", 1, false)
        end)
      end)
    end)

    describe("v.test", function()
      it("should pass when statement is true", function()
        assert.has_no.errors(function()
          g.v.test(true, "value", 1, false)
        end)
      end)

      it("should error when statement is false", function()
        assert.has_error(function()
          g.v.test(false, "value", 1, false)
        end)
      end)

      it("should allow nil value when nil_allowed", function()
        assert.has_no.errors(function()
          g.v.test(true, nil, 1, true)
        end)
      end)
    end)

    describe("v.not_nil", function()
      it("should pass for non-nil value", function()
        assert.has_no.errors(function()
          g.v.not_nil("hello", 1)
        end)
      end)

      it("should error for nil value", function()
        assert.has_error(function()
          g.v.not_nil(nil, 1)
        end)
      end)
    end)

    describe("v.same_type", function()
      it("should pass when both are same type", function()
        assert.has_no.errors(function()
          g.v.same_type("a", "b")
        end)
      end)

      it("should error when types differ", function()
        assert.has_error(function()
          g.v.same_type("a", 1)
        end)
      end)

      it("should default argument indices to 1 and 2", function()
        assert.has_no.errors(function()
          g.v.same_type(1, 2)
        end)
      end)

      it("should accept custom argument indices", function()
        assert.has_no.errors(function()
          g.v.same_type(1, 2, 3, 4)
        end)
      end)
    end)
  end)

  -- ========================================================================
  -- Glass.register
  -- ========================================================================

  describe("Glass.register", function()
    it("should return existing glass if already registered", function()
      local glass1 = Glu.get_glass("table")
      local glass2 = Glu.glass.register({
        name = "table",
        class_name = "TableClass",
        setup = function() end
      })
      assert.are.equal(glass1, glass2)
    end)

    it("should error on missing name", function()
      assert.has_error(function()
        Glu.glass.register({
          class_name = "TestClass",
          setup = function() end
        })
      end)
    end)

    it("should error on missing class_name", function()
      assert.has_error(function()
        Glu.glass.register({
          name = "test_glass_no_class",
          setup = function() end
        })
      end)
    end)

    it("should error on missing setup", function()
      assert.has_error(function()
        Glu.glass.register({
          name = "test_glass_no_setup",
          class_name = "TestClass"
        })
      end)
    end)

    it("should error on non-table opts", function()
      assert.has_error(function()
        Glu.glass.register("not a table")
      end)
    end)
  end)

  -- ========================================================================
  -- Dependency injection
  -- ========================================================================

  describe("dependencies", function()
    it("should resolve module dependencies", function()
      -- colour depends on number
      assert.is_truthy(g.colour)
      assert.is_truthy(g.number)
    end)

    it("should have all modules accessible from instance", function()
      local names = Glu.get_glass_names()
      for _, name in ipairs(names) do
        -- Every registered glass should be accessible on the instance
        assert.is_truthy(g[name], "Module '" .. name .. "' not found on instance")
      end
    end)
  end)

  -- ========================================================================
  -- handler_name (uninstall event)
  -- ========================================================================

  describe("uninstall handler", function()
    it("should have a handler_name set", function()
      assert.is_truthy(g.handler_name)
      assert.are.equal("string", type(g.handler_name))
    end)

    it("should start with glu_sysUninstall_", function()
      assert.is_truthy(g.handler_name:find("^glu_sysUninstall_"))
    end)
  end)
end)
