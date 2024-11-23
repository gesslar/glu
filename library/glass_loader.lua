---@meta GlassLoaderClass

------------------------------------------------------------------------------
-- GlassLoaderClass
------------------------------------------------------------------------------

if false then -- ensure that functions do not get defined

  ---@class GlassLoaderClass

  --- Loads a glass script from a path or url.
  ---@example
  ---```lua
  ---glass_loader.load_glass({
  ---  path = "path/to/glass.lua",
  ---  cb = function(result)
  ---    print(result)
  ---  end,
  ---  execute = true
  ---})
  ---```
  ---
  ---@param opts table - The options table.
  ---@param opts.path string - The path or url to the glass script.
  ---@param opts.cb function - The callback function.
  ---@param opts.execute boolean? - Whether to execute the glass script.
  ---@return any - The result of the glass script.
  function glass_loader.load_glass(opts) end

end
