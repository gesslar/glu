---@meta DependencyQueueClass

------------------------------------------------------------------------------
-- DependencyQueueClass
------------------------------------------------------------------------------

---@class DependencyQueueClass
dependency_queue = {}

if false then -- ensure that functions do not get defined

  --- Instantiates a new dependency queue for use with DependencyClass. When
  --- the queue is executed, it will install all the dependencies in the order
  --- they are given.
  ---
  ---@example
  ---```lua
  --- local queue = DependencyQueueClass.new_dependency_queue({
  ---   { name = "package_1", url = "https://example.com/package_1" },
  ---   { name = "package_2", url = "https://example.com/package_2" },
  --- }, function(success, error)
  ---   if success then
  ---     cecho("All dependencies installed successfully.\n")
  ---   else
  ---     cecho(f "Failed to install dependencies: {error}\n")
  ---   end
  --- end)
  ---
  ----- Alternate syntax
  ---
  --- local queue = glu.dependency_queue(...)
  ---```
  ---
  ---@name new_dependency_queue
  ---@param packages table - A table of dependency objects, each with a `name` and `url` property.
  ---@param cb function - A callback function that will be called with two arguments: `success` and `error`.
  function dependency_queue.new_dependency_queue(packages, cb) end

  --- Starts the dependency queue after it has been created. The callback will
  --- be called once all the dependencies have been installed or if there was an
  --- error.
  ---
  ---@example
  ---```lua
  ---local queue = glu.dependency_queue.new_dependency_queue(...)
  ---queue:start()
  ---```
  ---
  ---@name start
  function dependency_queue.start() end
end
