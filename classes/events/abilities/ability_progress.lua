--- This event ticks down the duration on the active ability of an
-- adventurer. If it falls below 0, it clears the ability on the
-- active ability. If it is being run on the host and it falls
-- below 0, it also fires an AbilityFinishedEvent
--
-- @classmod AbilityProgressEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local adventurers = require('functional/game_context/adventurers')

local simple_serializer = require('utils/simple_serializer')

local AbilityFinishedEvent = require('classes/events/abilities/ability_finished')
-- endregion

local AbilityProgressEvent = {}

simple_serializer.inject(AbilityProgressEvent)

function AbilityProgressEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error('AbilityProgressEvent requires adventurer (via adventurer_name)', 3)
  end

  if type(self.progress_game_ms) ~= 'number' then
    error('AbilityProgressEvent requires progress_game_ms (amount of progress made)', 3)
  end
end

function AbilityProgressEvent:process(game_ctx, local_ctx, networking)
  local advn = adventurers.get_by_name(game_ctx, self.adventurer_name)
  advn.active_ability.duration = advn.active_ability.duration - self.progress_game_ms

  if advn.active_ability.duration <= 0 then
    local abil = advn.active_ability
    self.ability = abil.ability
    advn.active_ability = nil

    if local_ctx.id ~= 0 then return end

    networking:broadcast_events(game_ctx, local_ctx, {
      AbilityFinishedEvent:new{ adventurer_name = self.adventurer_name, callback_event = abil.ability }
    })
  end
end

prototype.support(AbilityProgressEvent, 'event')
prototype.support(AbilityProgressEvent, 'serializable')
return class.create('AbilityProgressEvent', AbilityProgressEvent)
