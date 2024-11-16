local TryClass = Glu.glass.register({
  class_name = "TryClass",
  name = "try",
  inherit_from = nil,
  call = "clone",
  setup = function(___, self, opts)
    local result = {
      try = nil,
      catch = nil,
      finally = nil,
      result = nil
    }

    function self.clone(f, ...)
      local glass = ___.getGlass("try")
      assert(glass, "TryClass not found")
      local try = glass(opts, self)
      return try.try(f, ...)
    end

    -- first, let's try to execute the function
    function self.try(f, ...)
      local success, try_result, b = pcall(f, ...)
      if success and try_result then
        result.try = {
          success = success,
          error = nil,
          result = try_result
        }
        result.result = try_result
      else
        self.caught = true
        result.try = {
          success = success,
          error = try_result,
          result = nil
        }
      end

      return self
    end

    function self.catch(f)
      local success, catch_result = pcall(f, result.try)
      if success then
        catch_result.catch = { success = true, error = nil }
      end
      return self
    end

    function self.finally(f)
      -- Pass both success and error information to finally block
      local success, finally_result = pcall(f, result)

      -- If finally block itself errors, we should probably handle that
      if not success then
        error("Error in finally block: " .. finally_result)
      end
      return self
    end
  end
})
