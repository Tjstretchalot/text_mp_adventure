--- Raises the AbilityProgressEvent for adventurers with active abilities.
--
-- @classmod AbilityDurationListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local game_time = require('functional/game_time')

local AbilityProgressEvent = require('classes/events/abilities/ability_progress')
-- endregion


local AbilityDurationListener = {}

function AbilityDurationListener:get_events() return { TimeEvent = true } end
function AbilityDurationListener:is_prelistener() return false end
function AbilityDurationListener:is_postlistener() return true end
function AbilityDurationListener:compare(other, pre)
  if other == 'DayNightListener' then return -1 end
  return 0
end
function AbilityDurationListener:process(game_ctx, local_ctx, networking, event)
  if local_ctx.id ~= 0 then return end

  local _, _, _, _, ms_during_day, ms_during_night =
    game_time.add_real_time_to_game_ms_since_midnight(game_ctx.day.game_ms_since_midnight, event.ms)

  local game_time_passed = ms_during_day + ms_during_night
  for advn_ind, advn in ipairs(game_ctx.adventurers) do
    if advn.active_ability then
      networking:broadcast_events(game_ctx, local_ctx, { AbilityProgressEvent:new{adventurer_name = advn.name, progress_game_ms = game_time_passed} })
    end
  end
end

prototype.support(AbilityDurationListener, 'listener')
return class.create('AbilityDurationListener', AbilityDurationListener)
