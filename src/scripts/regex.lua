local script_name = "regex"
local class_name = script_name:title() .. "Class"
local deps = {}

local mod = Glu.registerClass({
  class_name = class_name,
  script_name = script_name,
  dependencies = deps,
})

function mod.setup(___, self, opts)
  self.http_url = "^(https?:\\/\\/)((([A-Za-z0-9-]+\\.)+[A-Za-z]{2,})|localhost)(:\\d+)?(\\/[^\\s]*)?$"
end
