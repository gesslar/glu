local DependencyClass = Glu.glass.register({
  class_name = "DependencyClass",
  name = "dependency",
  dependencies = { "dependency_queue", "table"},
  setup = function(___, self)
    self.queues = {}

    --- Install dependencies by including a table of tables that contains
    --- the name and URL of the package to install.
    ---
    --- The first failure will stop the installation process and call the
    --- callback.
    ---
    --- The callback is called with two arguments: a boolean indicating
    --- success or failure, and a message indicating the reason for the
    --- failure.
    ---
    --- @param packages table - A table of tables containing the name and URL of the package to install.
    --- @param cb function - A callback function that will be called when all dependencies are installed.
    --- @return table - A new instance of the DependencyQueue class.
    --- @example
    --- ```lua
    --- local packages = {
    ---   { name = "package1", url = "https://example.com/package1.mpackage" },
    ---   { name = "package2", url = "https://example.com/package2.mpackage" },
    --- }
    ---
    --- local cb = function(success, message)
    --- if success then
    ---   cecho("All dependencies installed successfully.\n")
    --- else
    ---   cecho(f"Failed to install dependencies: {message}\n")
    --- end
    ---
    --- local deps = dependency.new(packages, cb)
    --- deps:start()
    --- ```
    function self.new(packages, cb)
      local queue = ___.dependency_queue.new(packages, cb)
      ___.table.push(self.queues, queue)
      ---@diagnostic disable-next-line: return-type-mismatch
      return queue
    end
  end
})
