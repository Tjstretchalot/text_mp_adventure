--- The local ability event to determine if an adventurer
-- can *start* an ability.
--
-- @classmod LocalAbilityEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local event_serializer = require('functional/event_serializer')
-- endregion

local LocalAbilityEvent = {}

function LocalAbilityEvent:serialize()
  return {
    adventurer_name = self.adventurer_name,
    result = self.result,
    duration = self.duration,
    callback_event = event_serializer.serialize(self.callback_event)
  }
end

function LocalAbilityEvent.deserialize(serd)
  return LocalAbilityEvent._wrapped_class:new({
    adventurer_name = serd.adventurer_name,
    result = serd.result,
    duration = serd.duration,
    callback_event = event_serializer.deserialize(serd.callback_event)
  })
end

function LocalAbilityEvent:context_changed()
end

function LocalAbilityEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error('LocalAbilityEvent requires adventurer (via adventurer_name)', 3)
  end

  if type(self.result) == 'nil' then
    self.result = true
  elseif type(self.result) ~= 'boolean' then
    error('LocalAbilityEvent result is a boolean or nil to default to true, got ' .. type(self.result), 3)
  end

  if type(self.duration) ~= 'number' then
    error('LocalAbilityEvent requires a duration as a number!', 3)
  end

  if not class.is_class(self.callback_event) then
    error('LocalAbilityEvent requires a callback event!', 3)
  end
end

function LocalAbilityEvent:process(game_ctx, local_ctx)
end

prototype.support(LocalAbilityEvent, 'event')
prototype.support(LocalAbilityEvent, 'serializable')
return class.create('LocalAbilityEvent', LocalAbilityEvent)
