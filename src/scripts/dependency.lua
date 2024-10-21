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

  local function is_installed(pkg)
    return table.index_of(getPackages(), pkg)
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

    tempTimer(0.25, process_queue)
  end

  --- dependency:load_dependency(pkg, dependency)
  --- Loads a dependency.
  ---@param dependency table - The dependency.
  ---@param cb function - The callback function.
  ---@return nil
  function instance:load_dependency(dependency, cb)
    if requester then
      if cb then
        cb(false, "Dependency handler already in progress.")
      end
    end

    self.parent.valid:type(dependency, "table", 1, false)
    self.parent.valid:not_empty(dependency.name, 1, false)
    self.parent.valid:not_empty(dependency.url, 1, false)
    self.parent.valid:regex(dependency.url, self.parent.regex.http_url, 1, false)
    self.parent.valid:type(cb, "function", 2, true)

    if queue == nil then
      queue = { dependency }
      tempTimer(0.25, process_queue)
      return
    end

    if cb then call_back = cb end

    local pkg = package_name
    if not is_installed(dependency.name) then
      cecho(f "<b>{pkg}</b> is installing a dependent package: <b>{dependency.name}</b>\n")
      installPackage(dependency.url)
    else
      tempTimer(0.25, process_queue)
    end
  end

  --- dependency:load_dependencies(pkg, dependencies)
  --- Loads dependencies.
  ---@param pkg string - The package name.
  ---@param dependencies table - The dependencies.
  ---@param cb function - The callback function.
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
      return not is_installed(element.name)
    end)

    if not table.size(queue) then
      dependencies_done()
      return
    end


    call_back = cb
    requester = self
    registerNamedEventHandler("glu", handler_name_installed, "sysInstall", on_dependency_installed)

    tempTimer(0.25, process_queue)
  end

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
