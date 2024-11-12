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

  local function newObject(glu_instance, glass, instance_opts, container)
    instance_opts = instance_opts or {}
    container = container or glu_instance

    -- Check for circular dependencies
    local function checkIndexForLoop(ob)
      local seen = {}
      local current = ob

      while current do
        if seen[current] then
          error(">>   [newObject] Loop detected in __index chain for: " .. ob.name)
        end
        seen[current] = true
        current = getmetatable(current) and getmetatable(current).__index
      end
      return false
    end

    local function copyProperties(glu_class, into)
      local object = into[glu_class.name]
      for k, v in pairs(object) do
        glu_instance[glu_class.name][k] = v
      end

      -- Copy metatable info
      local meta = getmetatable(object)
      if meta then
        setmetatable(glu_instance[glu_class.name], meta)
      end
    end

    local function instantiate(glu, glu_class, ops, into)
      if checkIndexForLoop(glu_class) then return end
      -- If the class has a parent, make sure it is instantiated first
      if glu_class.inherit_from then
        local parent_name = glu_class.inherit_from
        local parent = into.getObject(parent_name)

        if not parent or (parent.glass and parent.glass.setup) then
          local parent_class = glu.getGlass(parent_name)
          -- Recursively instantiate the parent class
          return instantiate(glu, parent_class, ops, into)
          -- error("Parent class `" .. glu_class.inherit_from .. "` not found for `" .. glu_class.name .. "`")
        end
      end

      -- Instantiate the current class if it hasn't been already
      if not glu[glu_class.name] or table.index_of(table.keys(glu[glu_class.name]), "name") == nil then
        local object = glu_class(ops, glu)
        into[glu_class.name] = object   -- Add the instance to `instance`
        copyProperties(glu_class, into)
        return object
      end
    end

    return instantiate(glu_instance, glass, instance_opts, container)
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

    -- OOB Validation functions
    -- Standard validation functions
    local trace_ignore = debug.getinfo(1).source
    function instance.get_last_traceback_line()
      local it, trace = 1, ""
      while debug.getinfo(it) do
        if debug.getinfo(it).source ~= trace_ignore then
          local line = debug.getinfo(it).source ..
              ":" ..
              debug.getinfo(it).currentline
          trace = trace .. line .. "\n"
        end
        it = it + 1
      end

      if #trace == 0 then
        return "[No traceback]"
      end

      return trace
    end

    instance.v = {
      get_last_traceback_line = instance.get_last_traceback_line,
      test = function(statement, value, argument_index, nil_allowed)
        if nil_allowed and value == nil then
          return
        end

        local last = instance.get_last_traceback_line()
        assert(statement, "Invalid value to argument " .. argument_index ..
          ". " .. tostring(value) .. " in\n" .. last)
      end,
      type = function(value, expected_type, argument_index, nil_allowed)
        local last = instance.get_last_traceback_line()
        assert((nil_allowed == true and value == nil) or value ~= nil,
          "value must not be nil for argument " .. argument_index ..
          " in\n" .. last)
        assert(type(expected_type) == "string",
          "expected_type must be a string for argument " .. argument_index ..
          " in\n" .. last)
        assert(type(argument_index) == "number",
          "argument_index must be a number for argument " .. argument_index ..
          " in\n" .. last)
        assert(nil == nil_allowed or type(nil_allowed) == "boolean",
          "nil_allowed must be a boolean for argument " .. argument_index ..
          " in\n" .. last)

        if nil_allowed and value == nil then return end
        if expected_type == "any" then return end

        local expected_types = string.split(expected_type, "|") or { expected_type }
        local invalid = table.n_filter(expected_types, function(t) return not instance.TYPE[t] end)

        if table.size(invalid) > 0 then
          error("Invalid type to argument " ..
            argument_index .. ". Expected " .. table.concat(invalid, "|") .. ", got " .. type(value) .. " in\n" .. last)
        end

        for _, t in ipairs(expected_types) do
          if type(value) == t then return end
        end

        error("Invalid type to argument " ..
          argument_index .. ". Expected " .. expected_type .. ", got " .. type(value) .. " in\n" .. last)
      end
    }

    -- Let's now create them!
    for _, class in ipairs(registeredGlasses) do
      newObject(instance, class, {}, instance)
    end

    -- Trap events for uninstalling the package and clean ourselves up.
    local handler_name = "glu_sysUninstall_" .. Glu.id()
    instance.handler_name = handler_name
    registerNamedEventHandler("glu", handler_name, "sysUninstall",
      function(event, p)
        if p == instance.package_name then
          deleteNamedEventHandler("glu", handler_name)
          instance = nil
        end
      end
    )

    return instance
  end

  -- Glass
  Glass = {
    name = "glu_glass",
    class_name = "Glass",
    inherit_from = nil,
    dependencies = {},
    protect = function(glass, self)
      local function protect_function(object, function_name)
        assert(type(object) == "table", "`object` must be a table")
        assert(type(function_name) == "string", "`function_name` must be a string")

        local original_function = object[function_name]
        assert(type(original_function) == "function", "`original_function` must be a function")

        object[function_name] = function(caller, ...)
          if self.inherits(object) then
            return original_function(caller, ...)
          end
          error("Access denied: " .. function_name .. " is protected and can " ..
            "only be called by inheriting classes.")
        end
      end

      local function protect_variable(object, var_name)
        assert(type(object) == "table", "`object` must be a table")
        assert(type(var_name) == "string", "`var_name` must be a string")
        assert(type(object[var_name]) ~= "nil", "`object[var_name]` must not be nil")

        local base_class = getmetatable(object)

        setmetatable(object, {
          __index = function(tbl, key)
            if key == var_name and not self.inherits(tbl, base_class) then
              error("Access denied: Variable '" ..
                var_name .. "' is protected and can only be accessed by inheriting classes.")
            end
            return rawget(tbl, key)
          end,
          __newindex = function(tbl, key, value)
            if key == var_name and not self.inherits(tbl, base_class) then
              error("Access denied: Variable '" ..
                var_name .. "' is protected and can only be modified by inheriting classes.")
            end
            rawset(tbl, key, value)
          end,
        })
      end

      if glass.protected_functions then
        for _, function_name in ipairs(glass.protected_functions) do
          print("protecting function", function_name)
          protect_function(self, function_name)
        end
      end

      if glass.protected_variables then
        for _, var_name in ipairs(glass.protected_variables) do
          print("protecting variable", var_name)
          protect_variable(self, var_name)
        end
      end
    end,
    register = function(class_opts)
      assert(type(class_opts) == "table", "opts must be a table")
      assert(type(class_opts.name) == "string", "`name` must be a string")
      assert(type(class_opts.class_name) == "string", "`class_name` must " ..
        "be a string")
      assert(type(class_opts.inherit_from) == "string" or
        class_opts.inherit_from == nil,
        "`inherit_from` must be a string or nil")
      assert(type(class_opts.setup) == "function", "`setup` must " ..
        "be a function")
      assert(type(class_opts.valid) == "function" or class_opts.valid == nil,
        "`valid` must be a function or nil")

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
        valid = class_opts.valid,
        protected_functions = class_opts.protected_functions,
        protected_variables = class_opts.protected_variables,
      }

      function G.new(instance_opts, container)
        -- The instance_opts must be a table
        assert(type(instance_opts) == "table", "`instance_opts` must be " ..
          "a table")
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
          local inherit_from = class_opts.inherit_from
          local parent_instance = container.getObject(inherit_from)

          if not parent_instance then
            error("Instance of parent class `" .. inherit_from .. "` not " ..
              "found for `" .. class_opts.class_name .. "`")
          end

          self.parent = parent_instance

          setmetatable(self, { __index = parent_instance })
        else
          self.__index = self
        end

        -- Determine anchor
        local ___ = self
        repeat ___ = ___.container until not ___.container
        self.___ = ___

        for _, dep in ipairs(class_opts.dependencies or {}) do
          local obj = ___[dep]
          if not obj then
            local glass = ___.getGlass(dep)
            if not glass then
              error("Object `" .. dep .. "` not found for `" ..
                class_opts.class_name .. "`")
            end
          end
        end

        -- If we don't have a name, use a random UUID
        local instance_name = self.name or ___.id()

        -- Validation functions
        if G.valid and type(G.valid) == "function" then
          ___.v = ___.v or {}
          local valid = G.valid(___, self)
          if valid then
            for valid_function_name, valid_function in pairs(valid) do
              ___.v[valid_function_name] = valid_function
            end
          end
        end

        -- Add the instance to the container
        container.objects[instance_name] = self
        if table.index_of(table.keys(G), "setup") and
          type(G.setup) == "function" then
          -- Initialize the instance
          G.setup(___, self, instance_opts, container)
        end

        function self.inherits(base_class)
          local current_instance = self
          while current_instance do
            if current_instance == base_class then
              return true
            end
            current_instance = current_instance.parent
          end
          return false
        end

        -- Protect the functions and variables
        ___.glass.protect(G, self)

        assert(type(self.call) == "string" or self.call == nil,
          "`call` must be a string or nil")

        if self.call then
          local mt = getmetatable(self) or {}
          mt.__call = function(_, ...)
            local args = { ... }
            return self[self.call](unpack(args))
          end
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
