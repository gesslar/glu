local DirectoryClass = Glu.glass.register({
  class_name = "DirectoryClass",
  name = "directory",
  inherit_from = "file_system_object",
  dependencies = {},
  setup = function(___, self, opts, container)
    local v = self.v

    self:set_type("directory")

    if not opts then return end
    if not opts.path then return end

    v.dir(opts.path, 1)
    self.path = opts.path
  end
})
