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

  if self.type == 'set' and not self.adventurer_ind then
    error('Cannot set an adventurer unless you specify which', 3)
  end
end

function AdventurerEvent:process(game_ctx, local_ctx)
  if self.type == 'add' then
    adventurers.add_adventurer(game_ctx, self.name)
  elseif self.type == 'set' then
    adventurers.set_adventurer(game_ctx, self.player_id, self.adventurer_ind)
  elseif self.type == 'unset' then
    adventurers.unset_adventurer(game_ctx, self.player_id)
  end
end

prototype.support(AdventurerEvent, 'event')
prototype.support(AdventurerEvent, 'serializable')
return class.create('AdventurerEvent', AdventurerEvent)
