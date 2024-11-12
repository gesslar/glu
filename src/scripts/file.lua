local FileClass = Glu.glass.register({
  class_name = "FileClass",
  name = "file",
  inherit_from = "file_system_object",
  dependencies = {},
  setup = function(___, self, opts, container)
    self:set_type("file")
display(self)
    if not opts then return end
    if not opts.path then return end

    ___.v.file(opts.path, 1)
    self.path = opts.path
  end
})
