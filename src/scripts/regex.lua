local RegexClass = Glu.glass.register({
  name = "regex",
  class_name = "RegexClass",
  dependencies = {},
  setup = function(___, self)
    self.http_url = "^(https?:\\/\\/)((([A-Za-z0-9-]+\\.)+[A-Za-z]{2,})|localhost)(:\\d+)?(\\/[^\\s]*)?$"
  end
})
