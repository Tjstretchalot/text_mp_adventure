--- Resets the time when the game starts
-- @classmod ResetTimeOnStartGameListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')
-- endregion


local ResetTimeOnStartGameListener = {}

function ResetTimeOnStartGameListener:get_events() return { StartGameEvent = true } end
function ResetTimeOnStartGameListener:is_prelistener() return false end
function ResetTimeOnStartGameListener:is_postlistener() return true end
function ResetTimeOnStartGameListener:compare(other, pre) return 0 end
function ResetTimeOnStartGameListener:process(game_ctx, local_ctx, networking, event)
  game_ctx.day = { is_day = true, time_to_next_cycle_ms = 90000 }
end

prototype.support(ResetTimeOnStartGameListener, 'listener')
return class.create('ResetTimeOnStartGameListener', ResetTimeOnStartGameListener)
