--- Talking is detectable by other people in your location
-- @classmod TalkIsDetectableListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local adventurers = require('functional/game_context/adventurers')
local detection = require('functional/detection')
-- endregion

local TalkIsDetectableListener = {}

function TalkIsDetectableListener:get_events() return { TalkEvent = true } end
function TalkIsDetectableListener:is_prelistener() return false end
function TalkIsDetectableListener:is_postlistener() return true end
function TalkIsDetectableListener:compare(other, pre) return 0 end
function TalkIsDetectableListener:process(game_ctx, local_ctx, networking, event)
  if local_ctx.id ~= 0 then return end
  if event.name == 'server' then return end

  detection.determine_and_network_detection(game_ctx, local_ctx, networking, event.name, { TalkIsDetectableListener = true })
end

prototype.support(TalkIsDetectableListener, 'listener')
return class.create('TalkIsDetectableListener', TalkIsDetectableListener)
