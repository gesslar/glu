-- Define the class as a table
Glu = Glu or {}

local glu_modules = {}
registerAnonymousEventHandler("glu_module_loaded", function(_, name, mod)
  table.insert(glu_modules, { name = name, module = mod })
end)

-- Constructor function
---@param pkg string - The name of the package to which this module belongs.
function Glu.new(pkg)
  -- Create a new instance table
  local instance = {}

  assert(type(pkg) == "string", "Package name must be a string")
  assert(table.size(glu_modules) > 0, "No modules found in " .. pkg)

  for _, module in ipairs(glu_modules) do
    instance[module.name] = module.module.new(instance)
  end

  instance.package_name = pkg
  -- Public methods
  function instance:getPackageName()
    return self.package_name
  end

  return instance
end

-- Return the class
return Glu
