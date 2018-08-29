--- You shouldn't start the game with the original detections list
-- @classmod ResetDetectionsOnStartGameListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local AdventurerEvent = require('classes/events/adventurer')
-- endregion


local ResetDetectionsOnStartGameListener = {}

function ResetDetectionsOnStartGameListener:get_events() return { StartGameEvent = true } end
function ResetDetectionsOnStartGameListener:is_prelistener() return false end
function ResetDetectionsOnStartGameListener:is_postlistener() return true end
function ResetDetectionsOnStartGameListener:compare(other, pre) return 0 end
function ResetDetectionsOnStartGameListener:process(game_ctx, local_ctx, networking, event)
  for _, advn in ipairs(game_ctx.adventurers) do
    advn:clear_detected()
  end
end

prototype.support(ResetDetectionsOnStartGameListener, 'listener')
return class.create('ResetDetectionsOnStartGameListener', ResetDetectionsOnStartGameListener)
