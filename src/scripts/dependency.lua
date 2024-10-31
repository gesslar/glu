local script_name = "dependency"
local deps = { "queue", "table", "util", "valid", }

---@diagnostic disable-next-line: undefined-global
local function DependencyQueueClass()
  local DependencyQueue = {}

  function DependencyQueue.new(parent, packages, cb)
    local installed = getPackages()
    local not_installed = table.n_filter(packages, function(package)
      return table.index_of(installed, package.name) == nil
    end)

    -- We have no packages not installed, so just return as if we're done.
    if #not_installed == 0 then
      cecho("All dependencies are already installed.\n")
      cb(true, nil)
      return
    end

    local id = parent.___.util:generate_uuid()
    local handler_name = f "dependency_{id}_installed"
    local queue = parent.___.queue.new(
      parent.___.table:map(not_installed, function(_, package)
        return function()
          local name = package.name
          cecho(f "Installing dependency `<b>{name}</b>`...\n")
          installPackage(package.url)
        end
      end)
    )

    local instance = {
      id = id,
      cb = cb,
      queue = queue,
      packages = not_installed,
      parent = parent,
      handler_name = handler_name,
      ___ = (function(p)
        while p.parent do p = p.parent end
        return p
      end)(parent)
    }
    setmetatable(instance, { __index = DependencyQueue })

    registerNamedEventHandler("glu", instance.handler_name, "sysInstall",
      function(event, package)
        if package ~= instance.packages[1].name then return end

        instance.___.table:shift(instance.packages)
        tempTimer(1, function()
          local q, count = instance.queue:execute()
          if #instance.packages == 0 then
            instance.cb(true, nil)
            instance:clean_up()
          end
        end)
      end
    )

    registerNamedEventHandler("glu", handler_name .. "_download_error", "sysDownloadError",
      function(event, package)
        instance.cb(false, f"Failed to download dependency `<b>{package}</b>`.\nCleaning up.\n")
        instance:clean_up()
      end
    )

    function instance:clean_up()
      deleteNamedEventHandler("glu", self.handler_name)
      deleteNamedEventHandler("glu", self.handler_name .. "_download_error")
      self.handler_name = nil
      self.queue = nil
    end

    function instance:start()
      self.queue:execute()
    end

    return instance
  end

  return DependencyQueue
end

---@diagnostic disable-next-line: undefined-global
local mod = mod or {}

function mod.new(parent)
  local DependencyQueue = DependencyQueueClass()

  local instance = {
    parent = parent,
    queues = {},
    ___ = (function(p)
      while p.parent do p = p.parent end
      return p
    end)(parent)
  }
  setmetatable(instance, { __index = mod })

  -- Create a new queue for the given packages and add it to the instance.
  function instance.new(packages, cb)
    local queue = DependencyQueue.new(instance, packages, cb)
    instance.___.table:push(instance.queues, queue)
    return queue
  end

  -- Lazy-load dependencies
  local f = function(_, k) return function(...) end end
  for _, d in ipairs(deps) do
    instance.___[d] = instance.___[d] or setmetatable({}, { __index = f })
  end

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
