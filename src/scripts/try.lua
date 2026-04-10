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
      local success, try_result = pcall(f, ...)
      if success then
        result.try = {
          success = true,
          error = nil,
          result = try_result,
          caught = false
        }
        result.result = try_result
      else
        result.try = {
          success = false,
          error = try_result,
          result = nil,
          caught = true
        }
        result.result = nil
      end

      self.result = result
      self.caught = not success

      return self
    end

    function self.catch(f)
      local success, catch_result = pcall(f, result.try)
      if success then
        result.catch = {
          success = true,
          error = nil,
          result = nil
        }
      else
        result.catch = {
          success = false,
          error = catch_result,
          result = nil
        }
      end

      self.result = result
      return self
    end

    function self.finally(f)
      -- Pass both success and error information to finally block
      local success, finally_result = pcall(f, result)

      -- If finally block itself errors, we should probably handle that
      if not success then
        error("Error in finally block: " .. finally_result)
      end
      self.result = result
      return self
    end
  end
})
