---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "dependency"
function mod.new(parent)
  local instance = { parent = parent }
  local dependencies_done

  local handler_name_installed = nil
  local package_name = nil
  local call_back = nil
  local requester = nil
  local current = nil
  local queue = {}

  local function clean_up()
    deleteNamedEventHandler("glu", handler_name_installed)

    handler_name_installed = nil
    package_name = nil
    call_back = nil
    requester = nil
    current = nil
    queue = {}
  end

  local function process_queue()
    if #queue == 0 then
      dependencies_done()
      return
    end

    current = table.remove(queue, 1)

    if not current or not requester then
      return
    end

    requester:load_dependency(current)
  end

  function dependencies_done()
    local cb = call_back
    if cb then pcall(cb, true, nil) end
    clean_up()
  end

  local function on_dependency_installed(event, pkg)
    if not current or pkg ~= current.name then
      return
    end

    if #queue == 0 then
      dependencies_done()
      return
    end

    process_queue()
  end

  --- Checks if a package is installed. Returns true if it is, false otherwise.
  --- @example
  --- ```lua
  --- dependency:is_installed("generic_mapper")
  --- -- true
  --- ```
  --- @param pkg string - The package name.
  --- @return boolean - Whether the package is installed.
  function instance:is_installed(pkg)
    return table.index_of(getPackages(), pkg) > 0
  end

  --- Downloads and installs a dependency if it is not already installed.
  ---
  --- Packages are expected to be in the format:
  --- ```lua
  --- {
  ---   name = "package_name",
  ---   url = "http://example.com/package.mpackage"
  --- }
  --- ```
  ---
  --- If the callback function is provided, it will be called with two
  --- arguments: a boolean indicating whether the dependency was installed, and
  --- an error message if there was an error.
  --- @param dependency table - The dependency.
  --- @param cb function - The callback function (Optional).
  function instance:load_dependency(dependency, cb)
    if requester then
      if cb then
        cb(false, "Dependency handler already in progress.")
      end
    end

    self.parent.valid:type(dependency, "table", 1, false)
    self.parent.valid:type(dependency.name, "string", 1, false)
    self.parent.valid:regex(dependency.url, self.parent.regex.http_url, 1, false)
    self.parent.valid:type(cb, "function", 2, true)

    if queue == nil then
      queue = { dependency }
      process_queue()
      return
    end

    if cb then call_back = cb end

    local pkg = package_name
    if not self:is_installed(dependency.name) then
      cecho(f "<b>{pkg}</b> is installing a dependent package: <b>{dependency.name}</b>\n")
      installPackage(dependency.url)
    else
      process_queue()
    end
  end

  --- Downloads and installs a list of dependencies.
  ---
  --- All dependencies are queued and processed in order.
  ---
  --- Dependencies are expected to be in the format:
  --- ```lua
  --- {
  ---   {
  ---     name = "package_name_1",
  ---     url = "http://example.com/package_1.mpackage"
  ---   },
  ---   {
  ---     name = "package_name_2",
  ---     url = "http://example.com/package_2.mpackage"
  ---   },
  ---   ...
  --- }
  --- ```
  ---
  --- If the callback function is provided, it will be called with two
  --- arguments: a boolean indicating whether the dependencies were installed,
  --- and an error message if there was an error.
  --- @param pkg string - The package name.
  --- @param dependencies table - The dependencies.
  --- @param cb function - The callback function (Optional).
  function instance:load_dependencies(pkg, dependencies, cb)
    if requester then
      if cb then
        cb(false, "Dependency handler already in progress.")
      end
    end

    package_name = pkg
    handler_name_installed = f"dependency_{pkg}_installed"
    queue = dependencies
    queue = table.n_filter(queue, function(element)
      return not self:is_installed(element.name)
    end)

    if not table.size(queue) then
      dependencies_done()
      return
    end

    call_back = cb
    requester = self
    registerNamedEventHandler("glu", handler_name_installed, "sysInstall", on_dependency_installed)

    process_queue()
  end

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
