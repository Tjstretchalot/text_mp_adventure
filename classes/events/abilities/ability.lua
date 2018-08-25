--- Starts abilities. Takes an adventurer, duration, and an event
-- which will be queued if the ability starts and
--
-- 1. Calls the LocalAbilityEvent to verify the ability can be started.
-- 2. Sets the active_ability on the adventurer
-- 3. The AbilityDurationListener raises an AbilityProgressEvent for active abilities
-- 4. The AbilityProgressEvent counts down the duration an adventurers ability
-- 5. The AbilityFinishedEvent is fired once the duration hits 0
-- 6. The LocalAbilityFinishedEvent fires to determine if the finishing is successful
-- 7. If successful, the callback event is fired.
--
-- Note: this does actually go through the effort of serializing the event
-- so you should pass it a true event.
--
-- @classmod AbilityEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local event_serializer = require('functional/event_serializer')
local adventurers = require('functional/game_context/adventurers')

local LocalAbilityEvent = require('classes/events/abilities/local_ability')
local AdventurerEvent = require('classes/events/adventurer')
-- endregion

local AbilityEvent = {}

function AbilityEvent:serialize()
  return {
    adventurer_name = self.adventurer_name,
    duration = self.duration,
    callback_event = event_serializer.serialize(self.callback_event)
  }
end

function AbilityEvent:context_changed()
  -- we shouldn't have to worry about having a new reference to the
  -- callback event since we're the true owner of it; other people
  -- should copy our reference!
  -- Now you might say this is an issue since LocalAbilityEvent also
  -- does this, however that event shouldn't ever make it to the
  -- event queue.
end

function AbilityEvent.deserialize(serd)
  return AbilityEvent._wrapped_class:new({
    adventurer_name = serd.adventurer_name,
    duration = serd.duration,
    callback_event = event_serializer.deserialize(serd.callback_event)
  })
end

function AbilityEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error('AbilityEvent requires adventurer name as string; got ' .. type(self.adventurer_name), 3)
  end

  if type(self.duration) ~= 'number' then
    error('AbilityEvent requires duration as number; got ' .. type(self.duration), 3)
  end

  if not class.is_class(self.callback_event) then
    error('AbilityEvent requires callback_event as event; got ' .. type(self.callback_event), 3)
  end
end

function AbilityEvent:process(game_ctx, local_ctx, networking)
  if local_ctx.id ~= 0 then return end

  local local_evnt = LocalAbilityEvent:new{
    adventurer_name = self.adventurer_name,
    duration = self.duration,
    callback_event = self.callback_event
  }

  local_ctx.listener_processor:invoke_pre_listeners(game_ctx, local_ctx, nil, local_evnt)
  local_evnt:process(game_ctx, local_ctx)
  local_ctx.listener_processor:invoke_post_listeners(game_ctx, local_ctx, nil, local_evnt)

  if not local_evnt.result then return end

  if self.adventurer_name ~= local_evnt.adventurer_name then
    local_evnt.callback_event:set_source_adventurer_name(local_evnt.adventurer_name)
  end

  local evnt = AdventurerEvent:new{
    type = 'ability',
    adventurer_name = local_evnt.adventurer_name,
    ability = {
      duration = local_evnt.duration,
      ability = event_serializer.serialize(local_evnt.callback_event)
    }
  }

  networking:broadcast_events(game_ctx, local_ctx, { evnt })
end

prototype.support(AbilityEvent, 'event')
prototype.support(AbilityEvent, 'serializable')
return class.create('AbilityEvent', AbilityEvent)
