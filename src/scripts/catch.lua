local CatchClass = Glu.glass.register({
  class_name = "CatchClass",
  name = "catch",
  inherit_from = nil,
  call = "catch",
  dependencies = { "finally" },
  setup = function(___, self, opts)
    function self.catch(f, ...)
      local FinallyClass = Glu.getGlass("finally")
      assert(FinallyClass, "FinallyClass not found")

      if opts.try.success then
        -- If try succeeded, skip catch and go to finally
        return FinallyClass({
          catch = { success = true, err = nil },
          try = opts.try
        }, self)
      end

      -- Only execute catch if try failed
      local success, result = pcall(f, opts.try.err)
      return FinallyClass({
        catch = { success = success, err = result },
        try = opts.try
      }, self)
    end
  end
})
