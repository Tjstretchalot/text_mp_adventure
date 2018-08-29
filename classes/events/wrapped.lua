--- This event simply wraps another event and broadcasts it when
-- processed. This is a useful trick for manipulating when an
-- event gets processed.
-- @classmod WrappedEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local event_serializer = require('functional/event_serializer')
-- endregion

local WrappedEvent = {}

function WrappedEvent:serialize()
  return {
    callback_event = event_serializer.serialize(self.callback_event)
  }
end

function WrappedEvent:context_changed()
end

function WrappedEvent.deserialize(serd)
  return WrappedEvent._wrapped_class:new({
    callback_event = event_serializer.deserialize(serd.callback_event)
  })
end

function WrappedEvent:init()
  if not class.is_class(self.callback_event) then
    error('WrappedEvent requires a callback_event to raise!', 3)
  end
end

function WrappedEvent:process(game_ctx, local_ctx, networking)
  if local_ctx.id ~= 0 then return end

  networking:broadcast_events(game_ctx, local_ctx, { self.callback_event })
end

prototype.support(WrappedEvent, 'event')
prototype.support(WrappedEvent, 'serializable')
return class.create('WrappedEvent', WrappedEvent)
