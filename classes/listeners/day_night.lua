--- This adds a day/night cycle . 90s for day, 30s for night.
-- @classmod DayNightListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local TalkEvent = require('classes/events/talk')
-- endregion

local DayNightListener = {}

function DayNightListener:get_events() return { TimeEvent = true } end
function DayNightListener:is_prelistener() return false end
function DayNightListener:is_postlistener() return true end
function DayNightListener:process(game_ctx, local_ctx, networking, event)
  if game_ctx.day == nil then game_ctx.day = { is_day = true, time_to_next_cycle_ms = 90000 } end

  game_ctx.day.time_to_next_cycle_ms = game_ctx.day.time_to_next_cycle_ms - event.ms

  if game_ctx.day.time_to_next_cycle_ms <= 0 then
    if game_ctx.day.is_day then
      game_ctx.day.is_day = false
      game_ctx.day.time_to_next_cycle_ms = game_ctx.day.time_to_next_cycle_ms + 30000
      if local_ctx.id == 0 then
        networking:broadcast_events(game_ctx, local_ctx, {TalkEvent:new{id = -1, message = 'Night has begun!'}})
      end
    else
      game_ctx.day.is_day = true
      game_ctx.day.time_to_next_cycle_ms = game_ctx.day.time_to_next_cycle_ms + 90000

      if local_ctx.id == 0 then
        networking:broadcast_events(game_ctx, local_ctx, {TalkEvent:new{id = -1, message = 'Day has begun!'}})
      end
    end
  end
end

prototype.support(DayNightListener, 'listener')
return class.create('DayNightListener', DayNightListener)
