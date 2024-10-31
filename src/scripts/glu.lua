local script_name = "glu"

-- Define the class as a table
Glu = Glu or {}

local data_types = {
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
}

-- In the event that we have Glu as a package loaded in Mudlet, each module
-- must raise an event to let us know it's loaded.
local glu_modules = {}
registerAnonymousEventHandler("glu_module_loaded", function(_, name, mod)
  table.insert(glu_modules, { name = name, module = mod })
end)

-- In the event that we have added Glu in our package as resource files,
-- we need to detect those modules and load them.
local function detectModules(module_path, require_path)
  for file in lfs.dir(module_path) do
    if file:match("%.lua$") and file ~= script_name .. ".lua" then
      local module_name = file:match("^(.-)%.lua$")
      local require_file = string.format("%s/%s", require_path, module_name)
      assert(type(module_name) == "string", "Module name must be a string")
      assert(type(require_file) == "string", "Module file must be a string")

      local module = require(require_file)
      table.insert(glu_modules, { name = module_name, module = module })
    end
  end
end

--- Constructor for the Glu class.
--- @param pkg string - The name of the package to which this module belongs.
--- @param module_dir_name string - The directory name inside the package directory where the modules are located.
--- @return table - The Glu instance.
function Glu.new(pkg, module_dir_name)

  -- Create a new instance table
  local instance = {}

  assert(type(pkg) == "string", "Package name must be a string")

  instance.package_name = pkg

  if #glu_modules == 0 then
    local pkg_path = getMudletHomeDir() .. "/" .. pkg
    local module_path = pkg_path .. "/" .. module_dir_name
    local require_path = pkg .. "/" .. module_dir_name
    assert(type(module_dir_name) == "string", "Module directory name must be a string")
    assert(lfs.attributes(pkg_path), "Package directory " .. pkg .. " does not exist")
    assert(lfs.attributes(module_path), "Module directory " .. module_dir_name .. " does not exist in package " .. pkg)
    detectModules(module_path, require_path)

    -- Trap events for uninstalling the package and clean ourselves up.
    local handler_name = "glu_sysUninstall_" .. pkg
    registerNamedEventHandler("glu", handler_name, "sysUninstall", function(event, p)
      if p == instance.package_name then
        deleteNamedEventHandler("glu", handler_name)
        instance = nil
      end
    end)
  end

  assert(table.size(glu_modules) > 0, "No modules found in " .. pkg)

  for _, module in ipairs(glu_modules) do
    instance[module.name] = module.module.new(instance)
  end

  instance.package_name = pkg

  -- Public methods
  function instance:getPackageName()
    return self.package_name
  end

  -- Constants
  instance.TYPE = data_types

  -- Return the instance
  return instance
end

-- Return the class
return Glu
