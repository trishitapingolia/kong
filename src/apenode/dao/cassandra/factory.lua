-- Copyright (C) Mashape, Inc.
local Object = require "classic"
local cassandra = require "cassandra"

local Faker = require "apenode.tools.faker"
local Migrations = require "apenode.tools.migrations"

local Apis = require "apenode.dao.cassandra.apis"
local Metrics = require "apenode.dao.cassandra.metrics"
local Plugins = require "apenode.dao.cassandra.plugins"
local Accounts = require "apenode.dao.cassandra.accounts"
local Applications = require "apenode.dao.cassandra.applications"

local CassandraFactory = Object:extend()

-- Instanciate an SQLite DAO.
-- @param properties The parsed apenode configuration
function CassandraFactory:new(properties)
  self.type = "cassandra"
  self.migrations = Migrations(self)
  self._properties = properties

  self._db = cassandra.new()
  self._db:set_timeout(properties.timeout)

  self.apis = Apis(self._client)
  self.metrics = Metrics(self._client)
  self.plugins = Plugins(self._client)
  self.accounts = Accounts(self._client)
  self.applications = Applications(self._client)
  self:prepare()
end

--
-- Migrations
--
function CassandraFactory:migrate(callback)
  self.migrations:migrate(callback)
end

function CassandraFactory:rollback(callback)
  self.migrations:rollback(callback)
end

function CassandraFactory:reset(callback)
  self.migrations:reset(callback)
end

--
-- Seeding
--
function CassandraFactory:seed(random, number)
  Faker.seed(self, random, number)
end

function CassandraFactory.fake_entity(type, invalid)
  return Faker.fake_entity(type, invalid)
end

function CassandraFactory:drop()
  -- TODO
end

--
-- Utilities
--
function CassandraFactory:prepare()
 -- TODO
end

function CassandraFactory:execute(stmt)
  local connected, err = self._db:connect(self._properties.host, self._properties.port)
  if not connected then
    error(err)
  end

  -- Cassandra client doesn't support batches, splitting commands
  -- https://github.com/jbochi/lua-resty-cassandra/issues/26
  local queries = stringy.split(stmt, ";")
  for _,query in ipairs(queries) do
    if stringy.strip(query) ~= "" then
      local result, err = self._db:execute(query)
      if err then
        error(err)
      end
    end
  end
end

function CassandraFactory:close()
  self.apis:finalize()
  self.metrics:finalize()
  self.plugins:finalize()
  self.accounts:finalize()
  self.applications:finalize()

  local ok, err = self._db:close()
  if err ~= nil then
    error("Cannot close Cassandra session:".. err)
  end
end

return CassandraFactory
