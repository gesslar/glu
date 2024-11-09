local DependencyQueueClass = Glu.glass.register({
  class_name = "DependencyQueueClass",
  name = "dependency_queue",
  inherit_from = Glu.queue,
  dependencies = { "queue", "table", "valid" },
  setup = function(___, self, packages, cb)
    local installed = getPackages()
    local not_installed = ___.table.filter(packages, function(package)
      return ___.table.index_of(installed, package.name) == nil
    end)

    -- We have no packages not installed, so just return as if we're done.
    if #not_installed == 0 then
      cecho("All dependencies are already installed.\n")
      cb(true, nil)
      return
    end

    local id = ___.id()
    ___.table.add(self, {
      id = id,
      cb = cb,
      packages = not_installed,
      handler_name = f"dependency_{id}_installed",
    })

    for _, package in ipairs(not_installed) do
      self.push(self.id, function()
        cecho(f"Installing dependency `<b>{package.name}</b>`...\n")
        installPackage(package.url)
      end)
    end

    registerNamedEventHandler("glu", self.handler_name, "sysInstall",
      function(event, package)
        if package ~= self.packages[1].name then return end

        ___.table.shift(self.packages)
        tempTimer(1, function()
          local q, count = self.queue.execute()
          if #self.packages == 0 then
            self.cb(true, nil)
            self.clean_up()
          end
        end)
      end
    )

    registerNamedEventHandler("glu", self.handler_name .. "_download_error", "sysDownloadError",
      function(event, package)
        self.cb(false, f"Failed to download dependency `<b>{package}</b>`.\nCleaning up.\n")
        self.clean_up()
      end
    )

    function self.clean_up()
      deleteNamedEventHandler("glu", self.handler_name)
      deleteNamedEventHandler("glu", self.handler_name .. "_download_error")
      self.handler_name = nil
      self.queue = nil
    end

    function self.start()
      self.execute()
    end
  end
})

local DependencyClass = Glu.glass.register({
  class_name = "DependencyClass",
  name = "dependency",
  dependencies = { "queue", "table", "valid" },
  setup = function(___, self)
    self.queues = {}

    --- Install dependencies by including a table of tables that contains
    --- the name and URL of the package to install.
    ---
    --- The first failure will stop the installation process and call the
    --- callback.
    ---
    --- The callback is called with two arguments: a boolean indicating
    --- success or failure, and a message indicating the reason for the
    --- failure.
    ---
    --- @param packages table - A table of tables containing the name and URL of the package to install.
    --- @param cb function - A callback function that will be called when all dependencies are installed.
    --- @return table - A new instance of the DependencyQueue class.
    --- @example
    --- ```lua
    --- local packages = {
    ---   { name = "package1", url = "https://example.com/package1.mpackage" },
    ---   { name = "package2", url = "https://example.com/package2.mpackage" },
    --- }
    ---
    --- local cb = function(success, message)
    --- if success then
    ---   cecho("All dependencies installed successfully.\n")
    --- else
    ---   cecho(f"Failed to install dependencies: {message}\n")
    --- end
    ---
    --- local deps = dependency.new(packages, cb)
    --- deps:start()
    --- ```
    function self.new(packages, cb)
      local queue = DependencyQueueClass.new(packages, cb)
      ___.table.push(self.queues, queue)
      ---@diagnostic disable-next-line: return-type-mismatch
      return queue
    end
  end
})
