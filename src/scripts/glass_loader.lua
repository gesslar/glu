local GlassLoaderClass = Glu.glass.register({
  class_name = "GlassLoaderClass",
  name = "glass_loader",
  call = "load_glass",
  dependencies = { "try", "http", "fd", "string" },
  setup = function(___, self, instance_opts, container)

    function self.load_glass(opts)
      opts = opts or {}
      local path = opts.path
      local cb = opts.cb or opts.callback
      local execute = opts.execute

      if type(cb) ~= "function" then
        return false, "callback is required"
      end

      if not path then
        cb(nil, "No file or url provided")
        return
      end

      local function load_glass_from_data(data)
        local f, err = loadstring(data)
        if not f then
          return nil, "Failed to load glass from data: " .. tostring(err)
        end

        return f
      end

      local function finalize(result)
        if not result then
          return nil, "Failed to load glass from path"
        end

        if execute then
          local ok, err = pcall(result)
          if not ok then
            return nil, "Failed to execute glass: " .. tostring(err)
          end
        end

        return result
      end

      if ___.string.starts_with(path, "https?://") then
        ___.http.get({ url = path }, function(response)
          if response.result.error then
            cb(nil, "Failed to load glass from url: " .. response.result.error)
            return
          end

          local result, err = load_glass_from_data(response.result.data)
          if not result then
            cb(nil, err)
            return
          end

          local final, exec_err = finalize(result)
          if not final then
            cb(nil, exec_err)
            return
          end

          cb(final)
        end)
        return
      end

      local data, err = ___.fd.read_file(path)
      if not data then
        cb(nil, err)
        return
      end

      local result, load_err = load_glass_from_data(data)
      if not result then
        cb(nil, load_err)
        return
      end

      local final, exec_err = finalize(result)
      if not final then
        cb(nil, exec_err)
        return
      end

      cb(final)
    end
  end
})
