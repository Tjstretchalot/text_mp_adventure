--- Describes an event dealing with an adventurer
-- This is for high-level adventurer manipulation
-- @classmod AdventurerEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

local adventurers = require('functional/game_context/adventurers')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
-- endregion

local AdventurerEvent = {}

simple_serializer.inject(AdventurerEvent)

function AdventurerEvent:init()
  if not self.type then
    error('AdventurerEvent needs a type; add, set, or unset', 3)
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
end

function AdventurerEvent:process(game_ctx, local_ctx)
  local adventurer_ind = nil
  if self.adventurer_name then
    local advn, ind = adventurers.get_by_name(game_ctx, self.adventurer_name)
    adventurer_ind = ind
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
  end
end

prototype.support(AdventurerEvent, 'event')
prototype.support(AdventurerEvent, 'serializable')
return class.create('AdventurerEvent', AdventurerEvent)
