--- This adds a day/night cycle
-- Triggers the DayNightCycleEvent on the server when appropriate
-- @classmod DayNightListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local game_time = require('functional/game_time')
local system_messages = require('functional/system_messages')

local TalkEvent = require('classes/events/talk')
local DayNightCycleEvent = require('classes/events/day_night_cycle')
-- endregion

local DayNightListener = {}

function DayNightListener:get_events() return { NewGameEvent = true, TimeEvent = true } end
function DayNightListener:is_prelistener() return false end
function DayNightListener:is_postlistener() return true end
function DayNightListener:compare(other, pre) return 0 end
function DayNightListener:process(game_ctx, local_ctx, networking, event)
  if event.class_name == 'NewGameEvent' then
    game_ctx.day = { is_day = true, game_ms_since_midnight = game_time.GAME_MILLISECONDS_FOR_START_OF_DAY}
    return
  end

  local new_game_ms, day_cycled, daytime_cycled, is_day, ms_during_day, ms_during_night =
    game_time.add_real_time_to_game_ms_since_midnight(game_ctx.day.game_ms_since_midnight, event.ms)

  game_ctx.day.game_ms_since_midnight = new_game_ms
  game_ctx.day.is_day = is_day

  if local_ctx.id ~= 0 then return end

  if daytime_cycled then
    networking:broadcast_events(game_ctx, local_ctx, {DayNightCycleEvent:new{is_day = is_day}})

    local msg = is_day and 'Day has begun' or 'Night has begun'
    for advn_ind, advn in ipairs(game_ctx.adventurers) do
      system_messages:send(game_ctx, local_ctx, networking, advn_ind, msg, 0)
    end
  end
end

prototype.support(DayNightListener, 'listener')
return class.create('DayNightListener', DayNightListener)
