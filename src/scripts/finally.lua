local FinallyClass = Glu.glass.register({
  class_name = "FinallyClass",
  name = "finally",
  inherit_from = nil,
  call = "finally",
  setup = function(___, self, opts)
    function self.finally(f, ...)
      -- Pass both success and error information to finally block
      local success, result = pcall(f, {
        success = opts.catch.success,
        error = opts.catch.err,
        original_error = opts.try.err
      })
      -- If finally block itself errors, we should probably handle that
      if not success then
        print("Error in finally block:", result)
      end
      return self
    end
  end
})
