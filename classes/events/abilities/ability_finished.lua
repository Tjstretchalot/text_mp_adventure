--- This event is called when an adventurer has completed
-- an ability that required duration. It *will not* correspond
-- to the active_ability on the adventurer as that will have
-- been cleared already.
--
-- If this is running on the server, it uses the LocalAbilityFinishedEvent
-- to determine if the ability is successful. If it is successful, the callback
-- event is raised.
--
-- @classmod AbilityFinishedEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local adventurers = require('functional/game_context/adventurers')
local event_serializer = require('functional/event_serializer')

local LocalAbilityFinishedEvent = require('classes/events/abilities/local_ability_finished')
-- endregion

local AbilityFinishedEvent = {}

function AbilityFinishedEvent:serialize()
  return {
    adventurer_name = self.adventurer_name,
    callback_event = event_serializer.serialize(self.callback_event)
  }
end

function AbilityFinishedEvent:context_changed()
end

function AbilityFinishedEvent.deserialize(serd)
  return AbilityFinishedEvent._wrapped_class:new({
    adventurer_name = serd.adventurer_name,
    callback_event = event_serializer.deserialize(serd.callback_event)
  })
end

function AbilityFinishedEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error('AbilityFinishedEvent requires adventurer (via adventurer_name)', 3)
  end

  if not class.is_class(self.callback_event) then
    error('AbilityFinishedEvent requires a callback_event to raise on success!', 3)
  end
end

function AbilityFinishedEvent:process(game_ctx, local_ctx, networking)
  if local_ctx.id ~= 0 then return end

  local local_evnt = LocalAbilityFinishedEvent:new{
    adventurer_name = self.adventurer_name,
    callback_event = self.callback_event
  }

  local_ctx.listener_processor:invoke_pre_listeners(game_ctx, local_ctx, nil, local_evnt)
  local_evnt:process(game_ctx, local_ctx)
  local_ctx.listener_processor:invoke_post_listeners(game_ctx, local_ctx, nil, local_evnt)

  if not local_evnt.result then return end

  if self.adventurer_name ~= local_evnt.adventurer_name then
    local_evnt.callback_event:set_source_adventurer_name(local_evnt.adventurer_name)
  end

  networking:broadcast_events(game_ctx, local_ctx, { local_evnt.callback_event })
end

prototype.support(AbilityFinishedEvent, 'event')
prototype.support(AbilityFinishedEvent, 'serializable')
return class.create('AbilityFinishedEvent', AbilityFinishedEvent)
