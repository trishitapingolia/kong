local typedefs = require "kong.db.schema.typedefs"


return {
  name = "mesh-logger",
  fields = {
    {
      run_on = typedefs.run_on { default = "all" },
    },
  },
}
