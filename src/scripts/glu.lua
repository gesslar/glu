-- Glu cannot use GluClass because the constructors will be different. The
-- factory is for modules and any other classes in Glu.
if not _G["Glu"] then
  Glu = {}
  Glu.__index = Glu
  table.unpack = table.unpack or unpack

  local registeredClasses = {}
  function Glu.getClasses() return registeredClasses end
  function Glu.getClassNames() return table.keys(registeredClasses) end
  function Glu.getClass(name) return registeredClasses[name] end
  function Glu.hasClass(name) return registeredClasses[name] ~= nil end

  function Glu.id()
    local function random_hex(length)
      return string.format("%0" .. length .. "x", math.random(0, 16 ^ length - 1))
    end

    local result = string.format("%s%s-%s-4%s-%x%s-%s%s%s",
      random_hex(4),
      random_hex(4),
      random_hex(4),
      random_hex(3),
      8 + math.random(0, 3),
      random_hex(3),
      random_hex(4),
      random_hex(4),
      random_hex(4)
    )

    ---@diagnostic disable-next-line: return-type-mismatch
    return result
  end

   -- Make Glu callable
  setmetatable(Glu, {
    __call = function(_, ...)
      return Glu.new(...)
    end
  })

  --- Constructor for the Glu class.
  --- @param pkg string - The name of the package to which this module belongs.
  --- @param module_dir_name string|nil - The directory name inside the package directory where the modules are located.
  function Glu.new(pkg, module_dir_name)
    assert(type(pkg) == "string", "Package name must be a string.")
    assert(type(module_dir_name) == "string" or module_dir_name == nil, "Module directory name must be a string or nil.")

    local instance = {
      name = "Glu",
      package_name = pkg,
      module_dir_name = module_dir_name,
      objects = {},
      container = nil,
      TYPE = {
        BOOLEAN = "boolean",
        ["boolean"] = "boolean",
        FUNCTION = "function",
        ["function"] = "function",
        NIL = "nil",
        ["nil"] = "nil",
        NUMBER = "number",
        ["number"] = "number",
        STRING = "string",
        ["string"] = "string",
        TABLE = "table",
        ["table"] = "table",
        THREAD = "thread",
        ["thread"] = "thread",
        USERDATA = "userdata",
        ["userdata"] = "userdata",
      },
      ENUM_ELEMENT_TYPE = { INDEXED = 1, MIXED = 2 }
    }

    setmetatable(instance, Glu)

    -- In the event that we have added Glu in our package as resource files,
    -- we need to detect those modules and load them.
    local function detectModules(module_path, require_path)
      local filter = "glu.lua"

      for file in lfs.dir(module_path) do
        if file:match("%.lua$") and file ~= filter then
          local module_name = file:match("^(.-)%.lua$")
          local require_file = string.format("%s/%s", require_path, module_name)
          assert(type(module_name) == "string", "Module name must be a string")
          assert(type(require_file) == "string", "Module file must be a string")
          require(require_file) -- load the file. its event handler will fire
        end
      end
    end

    -- If the glu_modules table is empty, it means that we weren't loaded
    -- from a package with Mudlet. So, we have to detect the modules ourselves.
    if table.size(registeredClasses) == 0 then
      local pkg_path = getMudletHomeDir() .. "/" .. pkg
      local module_path = pkg_path .. "/" .. module_dir_name
      local require_path = pkg .. "/" .. module_dir_name
      assert(type(module_dir_name) == "string", "Module directory name must be a string")
      assert(lfs.attributes(pkg_path), "Package directory " .. pkg .. " does not exist")
      assert(lfs.attributes(module_path), "Module directory " .. module_dir_name .. " does not exist in package " .. pkg)
      detectModules(module_path, require_path)
    end

    -- Either way, we should have modules by now.
    assert(table.size(registeredClasses) > 0, "No modules found in " .. pkg)

    function instance.getPackageName() return instance.package_name end
    function instance.hasObject(name) return instance.getObject(name) ~= nil end
    function instance.getObject(name) return instance[name] and type(instance[name]) == "table" and instance[name] or nil end

    -- Instantiate all classes

    -- Step 1: Create placeholders in `instance` for all registered classes
    for name, _ in pairs(registeredClasses) do
      instance[name] = {} -- Create an empty table as a placeholder
    end

    -- Step 2: Instantiate all classes and update `instance`
    for name, class in pairs(registeredClasses) do
      -- Step 2a: Instantiate the class with placeholders, passing the anchor
      local object = class({ name = name }, instance)

      -- Step 2b: Copy properties and methods from the instantiated object to the placeholder
      for k, v in pairs(object) do
        instance[name][k] = v
      end
    end

    -- Trap events for uninstalling the package and clean ourselves up.
    local handler_name = "glu_sysUninstall_" .. Glu.id()
    instance.handler_name = handler_name
    registerNamedEventHandler("glu", handler_name, "sysUninstall", function(event, p)
      if p == instance.package_name then
        deleteNamedEventHandler("glu", handler_name)
        instance = nil
      end
    end)

    return instance
  end

  function Glu.registerClass(class_opts)
    assert(type(class_opts) == "table", "opts must be a table")
    assert(type(class_opts.script_name or class_opts.name) == "string", "`script_name` must be a string")
    assert(type(class_opts.class_name) == "string", "`class_name` must be a string")
    assert(type(class_opts.parent_class) == "table" or class_opts.parent_class == nil,
      "`parent_class` must be a table or nil"
    )

    local name = class_opts.script_name or class_opts.name

    -- Declare the class. And return it if it already exists.
    local Class = Glu.getClass(name)
    if Class then return Class end

    Class = {
      name = name,
      class_name = class_opts.class_name,
      parent_class = class_opts.parent_class,
      dependencies = class_opts.dependencies or {},
    }

    function Class.new(class, instance_opts, container)
      -- The instance_opts must be a table
      assert(type(instance_opts) == "table", "`instance_opts` must be a table")
      -- The container must be a table with a metatable
      assert(type(container) == "table", "`container` must be a table")

      -- Setup instance
      local self = {
        parent_class = class_opts.parent_class,
        class = class_opts.class_name,
        container = container,
        objects = {},
      }
      self.__index = self

      -- Determine anchor
      local ___ = self
      repeat ___ = ___.container until table.index_of(table.keys(___), "container") == nil
      self.___ = ___

      -- If we don't have a name, use the object's string representation
      local instance_name = instance_opts.name or ___.id()
      self.name = instance_name

      -- Add the instance to the container
      container.objects[instance_name] = self

      if table.index_of(table.keys(Class), "setup") and type(Class.setup) == "function" then
        -- Create module instance
        Class.setup(___, self, instance_opts, container)
      end

      return self
    end

    registeredClasses[name] = Class

    -- Set the metatable for the class. Always use the class's own `new` method for `__call`.
    setmetatable(Class, {
      __index = class_opts.parent_class or Class,
      __call = Class.new
    })

    return Class
  end
end
-- Return the class
return Glu
