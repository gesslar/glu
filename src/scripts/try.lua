local TryClass = Glu.glass.register({
  class_name = "TryClass",
  name = "try",
  inherit_from = nil,
  dependencies = { "catch", "finally" },
  call = "try",
  setup = function(___, self, opts)
    function self.try(f, ...)
      local CatchClass = Glu.getGlass("catch")
      local FinallyClass = Glu.getGlass("finally")

      assert(CatchClass, "CatchClass not found")
      assert(FinallyClass, "FinallyClass not found")

      local args = { ... }
      local success, result = pcall(function()
        return f(unpack(args))
      end)

      return CatchClass({
        try = {
          success = success,
          err = result,
          result = success and result or nil
        },
      }, self)
    end
  end
})
