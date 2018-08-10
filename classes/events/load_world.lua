--- This event cases us to replace game_ctx.world
-- @classmod LoadWorldEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
local World = require('classes/world/world')
-- endregion

local LoadWorldEvent = {}

simple_serializer.inject(LoadWorldEvent)

function LoadWorldEvent:init()
  if type(self.world) ~= 'table' then
    error('LoadWorldEvent called without a world to load!', 3)
  end

  if type(self.world.class_name) ~= 'nil' then
    error('LoadWorldEvent needs a serialized table for the world!', 3)
  end
end

function LoadWorldEvent:process(game_ctx, local_ctx)
  game_ctx.world = World.deserialize(self.world)
end

prototype.support(LoadWorldEvent, 'event')
prototype.support(LoadWorldEvent, 'serializable')
return class.create('LoadWorldEvent', LoadWorldEvent)
