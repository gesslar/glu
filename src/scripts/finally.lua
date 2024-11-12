local FinallyClass = Glu.glass.register({
  class_name = "FinallyClass",
  name = "finally",
  inherit_from = nil,
  call = "finally",
  setup = function(___, self, catch_result)
    function self.finally(f, ...)
      -- Pass both success and error information to finally block
      local success, result = pcall(f, {
        try = {
          success = catch_result.catch.success,
          err = catch_result.catch.err,
          result = catch_result.catch.result
        },
        catch = {
          success = catch_result.try.success,
          err = catch_result.try.err,
          result = catch_result.try.result
        }
      })
      -- If finally block itself errors, we should probably handle that
      if not success then
        print("Error in finally block:", result)
      end
      return self
    end
  end
})
