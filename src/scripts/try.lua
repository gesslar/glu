local TryClass = Glu.glass.register({
  class_name = "TryClass",
  name = "try",
  extends = nil,
  call = "clone",
  setup = function(___, self, opts)
    local result = {
      try = nil,
      catch = nil,
      finally = nil,
      result = nil
    }

    function self.clone(f, ...)
      local glass = ___.get_glass("try")
      assert(glass, "TryClass not found")
      local try = glass(opts, self)
      return try.try(f, ...)
    end

    -- first, let's try to execute the function
    function self.try(f, ...)
      local success, try_result, b = pcall(f, ...)
      result.try = {
        success = success,
        error = success and nil or try_result,
        result = success and try_result or nil,
        caught = not success
      }

      return self
    end

    function self.catch(f)
      local success, catch_result = pcall(f, result.try)
      result.catch = {
        success = success,
        error = success and nil or catch_result,
        result = not success and catch_result or nil
      }
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
