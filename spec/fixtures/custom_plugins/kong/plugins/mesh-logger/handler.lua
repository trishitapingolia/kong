local BasePlugin = require "kong.plugins.base_plugin"


local ngx = ngx
local kong = kong


local MeshLoggerHandler = BasePlugin:extend()


MeshLoggerHandler.PRIORITY = math.huge
MeshLoggerHandler.VERSION = "1.0.0"


local function is_mesh()
  if ngx.ctx.is_service_mesh_request == true then
    return "service-mesh"
  end

  return "gateway"
end


function MeshLoggerHandler:new()
  MeshLoggerHandler.super.new(self, "mesh-logger")
end


function MeshLoggerHandler:init_worker()
  MeshLoggerHandler.super.init_worker(self)
  kong.log.crit("init_worker: ", is_mesh())
end


function MeshLoggerHandler:certificate()
  MeshLoggerHandler.super.certificate(self)
  kong.log.crit("certificate: ", is_mesh())
end


function MeshLoggerHandler:rewrite()
  MeshLoggerHandler.super.rewrite(self)
  kong.log.crit("rewrite: ", is_mesh())
end


function MeshLoggerHandler:access()
  MeshLoggerHandler.super.header_filter(self)
  kong.log.crit("access: ", is_mesh())
end


function MeshLoggerHandler:header_filter()
  MeshLoggerHandler.super.header_filter(self)
  kong.log.crit("header_filter: ", is_mesh())
end


function MeshLoggerHandler:body_filter()
  MeshLoggerHandler.super.body_filter(self)
  kong.log.crit("body_filter: ", is_mesh())
end


function MeshLoggerHandler:preread()
  MeshLoggerHandler.super.preread(self)
  kong.log.crit("preread: ", is_mesh())
end


function MeshLoggerHandler:log()
  MeshLoggerHandler.super.log(self)
  kong.log.crit("log: ", is_mesh())
end


return MeshLoggerHandler
