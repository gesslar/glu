local FileSystemObjectClass = Glu.glass.register({
  class_name = "FileSystemObjectClass",
  name = "file_system_object",
  dependencies = { "table" },
  protected_variables = { "type" },
  protected_functions = { "set_type" },
  setup = function(___, self, opts, container)
    if not opts then return end

    -- if not opts.type then return end
    self.type = "file_system_object"

    function self:set_type(type)
      self.type = type
      return self
    end

    function self:get_type()
      return self.type
    end
  end
})
