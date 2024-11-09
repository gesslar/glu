-- Glu cannot use Glass because the constructors will be different. The
-- factory is for modules and any other classes in Glu.

if not _G["Glu"] then
  Glu = {}
  Glu.__index = Glu
  table.unpack = table.unpack or unpack

  local registeredGlasses = {}

  function Glu.getGlasses() return registeredGlasses end
  function Glu.getGlassNames()
    local names = {}
    local glasses = Glu.getGlasses()
    for _, glass in ipairs(glasses or {}) do
      table.insert(names, glass.name)
    end
    return names
  end
  function Glu.getGlass(name)
    for _, glass in ipairs(Glu.getGlasses()) do
      if glass.name == name then
        return glass
      end
    end
    return nil
  end
  function Glu.hasGlass(name)
    return Glu.getGlass(name) ~= nil
  end

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
  setmetatable(Glu, { __call = function(_, ...) return Glu.new(...) end })

  local function newObject(instance, glass, instance_opts, container)
    -- Check for circular dependencies
    local function checkIndexForLoop(g)
      local seen = {}
      local current = g

      while current do
        if seen[current] then
          print("Loop detected in __index chain for:", g.name)
          return true
        end
        seen[current] = true
        current = getmetatable(current) and getmetatable(current).__index
      end
      return false
    end

    local function copyProperties(c, i)
      local object = i[c.name]
      for k, v in pairs(object) do
        instance[c.name][k] = v
      end

      -- Copy and print metatable info
      local meta = getmetatable(object)
      if meta then
        setmetatable(instance[c.name], meta)
      end
    end

    local function instantiate(i, g, i_opts, cont)
      if checkIndexForLoop(g) then return end
      -- If the class has a parent, make sure it is instantiated first
      if g.inherit_from then
        local parentName = g.inherit_from.name

        if not i[parentName] or #table.keys(i[parentName]) == 0 then
          -- Recursively instantiate the parent class
          instantiate(g.inherit_from, i, i_opts, cont)
        end
      end

      -- Instantiate the current class if it hasn't been already
      if not i[g.name] or #table.keys(i[g.name]) == 0 then
        local object = g(i_opts, i)
        i[g.name] = object   -- Add the instance to `instance`
        copyProperties(g, i)
      end
    end

    instantiate(instance, glass, instance_opts, container)
  end

  --- Constructor for Glu.
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

    -- Add the Glass class to the instance
    instance.glass = Glu.glass

    setmetatable(instance, Glu)

    -- If the glu_modules table is empty, it means that we weren't loaded
    -- from a package with Mudlet. So, we have to detect the modules ourselves.
    if table.size(registeredGlasses) == 0 then
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

      local pkg_path = getMudletHomeDir() .. "/" .. pkg
      local module_path = pkg_path .. "/" .. module_dir_name
      local require_path = pkg .. "/" .. module_dir_name
      assert(type(module_dir_name) == "string", "Module directory name must be a string")
      assert(lfs.attributes(pkg_path), "Package directory " .. pkg .. " does not exist")
      assert(lfs.attributes(module_path), "Module directory " .. module_dir_name .. " does not exist in package " .. pkg)
      detectModules(module_path, require_path)
    end

    -- Either way, we should have modules by now.
    assert(table.size(registeredGlasses) > 0, "No modules found in " .. pkg)

    function instance.getPackageName() return instance.package_name end
    function instance.hasObject(name) return instance.getObject(name) ~= nil end
    function instance.getObject(name) return instance[name] and type(instance[name]) == "table" and instance[name] or nil end

    -- Instantiate all classes
    -- Step 1: Create placeholders in `instance` for all registered classes
    for _, class in ipairs(registeredGlasses) do
      instance[class.name] = {} -- Create an empty table as a placeholder
    end

    -- Instantiate all classes
    for _, class in ipairs(registeredGlasses) do
      local instance_opts = { name = class.name }
      newObject(instance, class, instance_opts, instance)
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

  -- Glass
  Glass = {
    name = "glu_glass",
    class_name = "Glass",
    inherit_from = nil,
    dependencies = {},
    register = function(class_opts)
      assert(type(class_opts) == "table", "opts must be a table")
      assert(type(class_opts.name) == "string", "`name` must be a string")
      assert(type(class_opts.class_name) == "string", "`class_name` must be a string")
      assert(type(class_opts.inherit_from) == "table" or class_opts.inherit_from == nil,
        "`inherit_from` must be a table or nil")
      -- assert(type(class_opts.setup) == "function" or class_opts.setup == nil, "`setup` must be a function or nil")
      assert(type(class_opts.setup) == "function", "`setup` must be a function")

      local name = class_opts.name

      -- Declare the class. And return it if it already exists.
      local G = Glu.getGlass(name)
      if G then return G end

      G = {
        name = name,
        class_name = class_opts.class_name,
        inherit_from = class_opts.inherit_from,
        dependencies = class_opts.dependencies or {},
        setup = class_opts.setup,
      }

      function G.new(instance_opts, container)
        -- The instance_opts must be a table
        assert(type(instance_opts) == "table", "`instance_opts` must be a table")
        -- The container must be a table with a metatable
        assert(type(container) == "table", "`container` must be a table")

        -- Setup instance
        local self = {
          inherit_from = class_opts.inherit_from,
          name = class_opts.name,
          class = class_opts.class_name,
          call = class_opts.call,
          container = container,
          objects = {},
          object = true,
        }
        self.__index = self

        -- Set the __index for inheritance if there is a parent class
        if class_opts.inherit_from then
          local inherit_from_name = class_opts.inherit_from.name
          local parent_instance = container.objects[inherit_from_name]

          if not parent_instance then
            error("Instance of parent class `" .. inherit_from_name .. "` not found for `" .. class_opts.class_name .. "`")
          end

          self.parent = parent_instance

          if class_opts.call then
            self[class_opts.call] = parent_instance[class_opts.call]
          end
          setmetatable(self, { __index = parent_instance })
        else
          self.__index = self
        end

        -- Determine anchor
        local ___ = self
        repeat
          ___ = ___.container
        until not ___.container
        self.___ = ___

        for _, dep in ipairs(class_opts.dependencies or {}) do
          local obj = ___[dep]
          if not obj then
            error("Object `" .. dep .. "` not found for `" .. class_opts.class_name .. "`")
          end
        end

        -- If we don't have a name, use a random UUID
        local instance_name = instance_opts.name or ___.id()
        self.name = instance_name

        -- Add the instance to the container
        container.objects[instance_name] = self
        if table.index_of(table.keys(G), "setup") and type(G.setup) == "function" then
          -- Initialize the instance
          G.setup(___, self, instance_opts, container)
        end

        assert(type(class_opts.call) == "string" or class_opts.call == nil, "`call` must be a string or nil")
        if class_opts.call then
          local mt = getmetatable(self) or {}
          mt.__call = function(_, ...) return self[class_opts.call](...) end
          setmetatable(self, mt)
        end

        return self
      end

      table.insert(registeredGlasses, G)

      -- Set the metatable for the class. Always use the class's own `new` method for `__call`.
      setmetatable(G, {
        __index = class_opts.inherit_from or nil,
        __call = function(_, ...) return G.new(...) end
      })
      return G
    end
  }
  setmetatable(Glass, {
    __index = Glass,
    __call = function(_, ...) return Glass.new(...) end
  })
  Glu.glass = Glass
end
