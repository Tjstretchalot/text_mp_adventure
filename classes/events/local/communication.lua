--- This event is used as a signal for determining if communication is
-- possible between two adventurers and is not meant to be networked.
-- This event is specifically for standard communication, not for abilities.
-- @classmod CommunicationEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
-- endregion

local CommunicationEvent = {}

simple_serializer.inject(CommunicationEvent)

function CommunicationEvent:init()
  if type(self.from_id) ~= 'number' then
    error('CommunicationEvent missing from_id (the id of the adventurer the message is coming from)')
  end

  if type(self.to_id) ~= 'number' then
    error('CommunicationEvent missing to_id (the id of the adventurer the message is going to)')
  end

  if type(self.result) == 'nil' then
    self.result = true
  elseif type(self.result) ~= 'boolean' then
    error('CommunicationEvent has a bad result set from new (should be unset or true): ' .. tostring(self.result))
  end
end

function CommunicationEvent:process(game_ctx, local_ctx)
end

prototype.support(CommunicationEvent, 'event')
prototype.support(CommunicationEvent, 'serializable')
return class.create('CommunicationEvent', CommunicationEvent)
