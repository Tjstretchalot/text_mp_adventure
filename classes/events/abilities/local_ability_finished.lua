--- This event is fired to determine if an ability is successful.
-- In order to allow random results this is run only once, locally,
-- on the host.
--
-- @classmod LocalAbilityFinishedEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local event_serializer = require('functional/event_serializer')
-- endregion

local LocalAbilityFinishedEvent = {}

function LocalAbilityFinishedEvent:serialize()
  return {
    adventurer_name = self.adventurer_name,
    result = self.result,
    callback_event = event_serializer.serialize(self.callback_event)
  }
end

function LocalAbilityFinishedEvent.deserialize(serd)
  return LocalAbilityFinishedEvent._wrapped_class:new({
    adventurer_name = serd.adventurer_name,
    result = serd.result,
    callback_event = event_serializer.deserialize(serd.callback_event)
  })
end

function LocalAbilityFinishedEvent:context_changed()
end

function LocalAbilityFinishedEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error('LocalAbilityFinishedEvent requires adventurer (via adventurer_name)', 3)
  end

  if type(self.result) == 'nil' then
    self.result = true
  elseif type(self.result) ~= 'boolean' then
    error('LocalAbilityFinishedEvent result is a boolean or nil to default to true, got ' .. type(self.result), 3)
  end

  if not class.is_class(self.callback_event) then
    error('LocalAbilityFinishedEvent requires a callback event!', 3)
  end
end

function LocalAbilityFinishedEvent:process(game_ctx, local_ctx)
end

prototype.support(LocalAbilityFinishedEvent, 'event')
prototype.support(LocalAbilityFinishedEvent, 'serializable')
return class.create('LocalAbilityFinishedEvent', LocalAbilityFinishedEvent)
