--- This event is raised if an ability was started with an AbilityEvent
-- but then was cancelled before it was finished. This is NOT equivalent
-- to an ability failing to get started (use a postlistener on a LocalAbilityEvent
-- and check for result = false for that)
--
-- This event sets the active abilty of the adventurer to nil. Use a prelistener
-- to determine the old ability.
--
-- @classmod AbilityCancelledEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local adventurers = require('functional/game_context/adventurers')

local simple_serializer = require('utils/simple_serializer')
-- endregion

local AbilityCancelledEvent = {}

simple_serializer.inject(AbilityCancelledEvent)

function AbilityCancelledEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error('AbilityCancelledEvent requires adventurer (via adventurer_name)', 3)
  end
end

function AbilityCancelledEvent:process(game_ctx, local_ctx)
  local advn = adventurers.get_by_name(game_ctx, self.adventurer_name)
  self.ability = advn.active_ability.ability
  advn.active_ability = nil
end

prototype.support(AbilityCancelledEvent, 'event')
prototype.support(AbilityCancelledEvent, 'serializable')
return class.create('AbilityCancelledEvent', AbilityCancelledEvent)
