---@meta Glass

------------------------------------------------------------------------------
-- Glass
------------------------------------------------------------------------------

if false then -- ensure that functions do not get defined

  ---@class Glass

  ---Register a class with the Glu framework.
  ---
  ---The following options are available:
  ---
  ---* `class_name` string - The name of the class, usually in the form of `NameClass`.
  ---* `name` string - The name of the class, usually in the form of `name`.
  ---* `inherit_from` string? - The class to inherit from, in the form of the class's `name`.
  ---* `dependencies` string[] - The dependencies of the class, in the form of the class's `name` .
  ---* `inherit` table<string, function> - The functions to inherit, in the form of `function_name = function(self, ...) end`.
  ---* `setup` function - The setup function, in the form of `function(self, ...) end`.
  ---* `valid` function - The valid function, in the form of `function(self, ...) end`.
  ---
  ---@name register
  ---@param class_opts table - The class options.
  ---@return Glass # The class.
  function Glass.register(class_opts) end

end
