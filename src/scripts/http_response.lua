local HttpResponseClass = Glu.glass.register({
  name = "http_response",
  class_name = "HttpResponseClass",
  dependencies = { "table" },
  setup = function(___, self, response)
    self.id = response.id
    self.result = response
  end
})
