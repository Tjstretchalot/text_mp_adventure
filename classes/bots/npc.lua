--- NPC bot
-- Wanders between the open market during the day and a nearby building at night.
-- Currently just alternates between the church and open market.
-- @classmod NPCBot

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/bot')
require('prototypes/listener')
require('prototypes/serializable')

local adventurers = require('functional/game_context/adventurers')
local simple_serializer = require('utils/simple_serializer')

local MoveCommandEvent = require('classes/events/move_command')
-- endregion

local NPCBot = {}

function NPCBot:init()
  if type(self.adventurer_name) ~= 'string' then
    error('NPCBot missing adventurer_name!', 3)
  end
end

-- region serializer prototype
simple_serializer.inject(NPCBot)
-- endregion

-- region bot prototype
function NPCBot:get_adventurer_name()
  return self.adventurer_name
end
-- endregion

-- region listener prototype
function NPCBot:get_events() return { DayNightCycleEvent = true } end
function NPCBot:is_prelistener() return false end
function NPCBot:is_postlistener() return true end
function NPCBot:compare(other, pre) return 0 end
function NPCBot:process(game_ctx, local_ctx, networking, event)
  if local_ctx.id ~= 0 then return end
  if game_ctx.in_setup_phase then return end

  local advn, advn_ind = adventurers.get_by_name(game_ctx, self.adventurer_name)

  if advn.locations[1] == 'open_market' and not event.is_day then
    networking:broadcast_events(game_ctx, local_ctx, { MoveCommandEvent:new{adventurer_name = self.adventurer_name, destination = 'church'} })
  elseif advn.locations[1] == 'church' and event.is_day then
    networking:broadcast_events(game_ctx, local_ctx, { MoveCommandEvent:new{adventurer_name = self.adventurer_name, destination = 'open_market'} })
  end
end
-- endregion

prototype.support(NPCBot, 'serializable')
prototype.support(NPCBot, 'bot')
prototype.support(NPCBot, 'listener')
return class.create('NPCBot', NPCBot)
