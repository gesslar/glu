local DependencyQueueClass = Glu.glass.register({
  class_name = "DependencyQueueClass",
  name = "dependency_queue",
  extends = "queue",
  call = "new_dependency_queue",
  dependencies = {"queue", "table",},
  setup = function(___, self)
    function self.new_dependency_queue(packages, cb)
      local installed = getPackages()
      local not_installed = table.n_filter(packages, function(package)
        return table.index_of(installed, package.name) == nil
      end) or {}

      -- We have no packages not installed, so just return as if we're done.
      if #not_installed == 0 then
        cb(true, "All dependencies are already installed.")
        return
      end

      local this = {
        id = ___.id(),
        cb = cb,
        queue = self.new_queue(),
        packages = not_installed,
        handler_name = f "dependency_{id}_installed",
      }
      ___.table.add(self, this)

      for _, package in ipairs(not_installed) do
        local func = function()
          cecho("Installing dependency `<b>" .. package.name .. "</b>`...\n")
          installPackage(package.url)
        end

        self.queue.push(func)
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
        if not self.queue then
          return nil, "Queue not found"
        end
        return self.queue.execute()
      end

      return self
    end
  end
})
