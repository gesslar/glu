local GlassLoaderClass = Glu.glass.register({
  class_name = "GlassLoaderClass",
  name = "glass_loader",
  call = "load_glass",
  dependencies = { "try" },
  setup = function(___, self, instance_opts, container)

    function self.load_glass(opts)
      local path = opts.path
      local cb = opts.cb or opts.callback
      local execute = opts.execute
      local path_type = ___.string.starts_with(path, "https?://") and "url" or "path"

      local tried = ___
        .try(function()
          local function load_glass_from_data(data)
            local f = loadstring(data)

            return f or false, "Failed to load glass from data"
          end

          local function done(result)
            if not result then
              return false, "Failed to load glass from path"
            end

            if execute then
              local load_result
              local load_try = ___
                .try(function()
                  load_result = result()
                end)
                .catch(function(catch_result)
                  return false, "Failed to execute glass: " .. catch_result.try.error
                end)
            end

            return result
          end

          if not path then return false, "No file or url provided" end

          if path_type == "url" then
            local request = ___.http.get({ url = path }, function(response)
              if response.result.error then
                return false, "Failed to load glass from url: " .. response.result.error
              end

              return done(load_glass_from_data(response.result.data))
            end)
          else
            local data, err, code = ___.fd.read_file(path)
            if not data then return false, err end

            return done(load_glass_from_data(data))
          end
        end)
      if tried.caught then
        tried.catch(function(result)
          cb(nil, "Failed to load glass from " .. path_type .. ": " .. result.try.error)
        end)
      else
        cb(tried.result.result)
      end
    end
  end
})
