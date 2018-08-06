--- This event is broadcast when a client connects to the server.
-- This event serves as a marker for listeners, but it also maintains
-- the client_id_counter for consistency.
-- @classmod ClientConnectEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
-- endregion

local ClientConnectEvent = {}

simple_serializer.inject(ClientConnectEvent)

function ClientConnectEvent:init()
  if not self.id then
    error('Connect events need an id!', 3)
  end
end

function ClientConnectEvent:process(game_ctx, local_ctx)
  if local_ctx.id ~= 0 then
    if (not game_ctx.client_id_counter) or game_ctx.client_id_counter < self.id then
      game_ctx.client_id_counter = self.id
    end
  end
end

prototype.support(ClientConnectEvent, 'event')
prototype.support(ClientConnectEvent, 'serializable')
return class.create('ClientConnectEvent', ClientConnectEvent)
