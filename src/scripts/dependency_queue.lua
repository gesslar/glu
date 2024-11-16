local DependencyQueueClass = Glu.glass.register({
  class_name = "DependencyQueueClass",
  name = "dependency_queue",
  inherit_from = "queue",
  call = "new_dependency_queue",
  dependencies = {"queue", "table",},
  setup = function(___, self)
    function self.new_dependency_queue(packages, cb)
      local installed = getPackages()
      local not_installed = table.n_filter(packages, function(package)
        return ___.table.index_of(installed, package.name) == nil
      end) or {}

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
        handler_name = f "dependency_{id}_installed",
      })

      for _, package in ipairs(not_installed) do
        self.push(self.id, function()
          cecho(f "Installing dependency `<b>{package.name}</b>`...\n")
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
          self.cb(false, f "Failed to download dependency `<b>{package}</b>`.\nCleaning up.\n")
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
  end
})
