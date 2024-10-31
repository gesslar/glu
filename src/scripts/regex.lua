---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "regex"

function mod.new(parent)
  local instance = {
    parent = parent,
    ___ = (function(p)
      while p.parent do p = p.parent end
      return p
    end)(parent)
  }

  --- Standard patterns
  instance.http_url = "^(https?:\\/\\/)((([A-Za-z0-9-]+\\.)+[A-Za-z]{2,})|localhost)(:\\d+)?(\\/[^\\s]*)?$"

  instance.___.valid = instance.___.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
