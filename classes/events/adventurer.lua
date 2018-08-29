--- Describes an event dealing with an adventurer
-- This is for low-level adventurer manipulation;
-- typically you would fire another event that then
-- fires this event (eg MoveEvent would fire an AdventurerEvent)
--
-- The advantage of this class is it makes adding new visualizers (alternatives
-- to the CLI) much easier to accomplish rather than hunting down all the
-- correct events
--
-- @classmod AdventurerEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

local adventurers = require('functional/game_context/adventurers')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
local event_serializer = require('functional/event_serializer')
-- endregion

local AdventurerEvent = {}

simple_serializer.inject(AdventurerEvent)

function AdventurerEvent:init()
  if not self.type then
    error('AdventurerEvent needs a type', 3)
  end

  if self.type == 'add' and not self.name then
    error('Cannot add an adventurer without a name!', 3)
  end

  if (self.type == 'set' or self.type == 'unset') and not self.player_id then
    error('Cannot set/unset adventurer without a player id', 3)
  end

  if self.type == 'set' and not self.adventurer_name then
    error('Cannot set an adventurer unless you specify which', 3)
  end

  if self.type == 'move' and (not self.adventurer_name or not self.location_name) then
    error('Cannot move an adventurer unless who specify which adventurer (adventurer_name) and to where (location_name)', 3)
  end

  if self.type == 'spec' and (not self.adventurer_name or not self.specialization) then
    error('Cannot set an adventurers specialization unless you specify which adventurer (adventurer_name) and what specialization (specialization)', 3)
  end

  if self.type == 'ability' and (not self.adventurer_name or not self.ability or not self.ability.duration or not self.ability.ability) then
    error('Cannot set an adventurers active ability unless you specify which adventurer (adventurer_name) and the ability duration (ability.duration) and the serialized event (ability.ability)', 3)
  end

  if self.type == 'add_detect' and (not self.adventurer_name or not self.detected_name) then
    error('Cannot add to detectors without which adventurer (adventurer_name) and who to add (detected_name)', 3)
  end

  if self.type == 'remove_detect' and (not self.adventurer_name or not self.detected_name) then
    error('Cannot remove from detectors without which adventurer (adventurer_name) and who to remove (detected_name)', 3)
  end

  if self.type == 'clear_detect' and (not self.adventurer_name) then
    error('Cannot clear detected without specifying adventurer (adventurer_name)', 3)
  end
end

function AdventurerEvent:process(game_ctx, local_ctx)
  local advn = nil
  local adventurer_ind = nil
  if self.adventurer_name then
    local _advn, ind = adventurers.get_by_name(game_ctx, self.adventurer_name)
    adventurer_ind = ind
    advn = _advn
  end

  if self.type == 'add' then
    adventurers.add_adventurer(game_ctx, self.name)
  elseif self.type == 'set' then
    adventurers.set_adventurer(game_ctx, self.player_id, adventurer_ind)
  elseif self.type == 'unset' then
    adventurers.unset_adventurer(game_ctx, self.player_id)
  elseif self.type == 'move' then
    local loc = game_ctx.locations[self.location_name]
    if not loc then error('Bad location ' .. tostring(self.location_name)) end

    game_ctx.adventurers[adventurer_ind]:replace_location(self.location_name)
  elseif self.type == 'spec' then
    adventurers.set_specialization(game_ctx, adventurer_ind, self.specialization)
  elseif self.type == 'ability' then
    adventurers.set_ability(game_ctx, adventurer_ind, {
      duration = self.ability.duration,
      ability = event_serializer.deserialize(self.ability.ability)
    })
  elseif self.type == 'add_detect' then
    advn:add_detected(self.detected_name)
  elseif self.type == 'remove_detect' then
    advn:remove_detected(self.detected_name)
  elseif self.type == 'clear_detect' then
    advn:clear_detected()
  end
end

prototype.support(AdventurerEvent, 'event')
prototype.support(AdventurerEvent, 'serializable')
return class.create('AdventurerEvent', AdventurerEvent)
