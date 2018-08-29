--- When we detect someone, we should be notified
-- @classmod AlertOnDetectListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local adventurers = require('functional/game_context/adventurers')
local system_messages = require('functional/system_messages')
-- endregion

local AlertOnDetectListener = {}

function AlertOnDetectListener:get_events() return { LocalDetectableEvent = true } end
function AlertOnDetectListener:is_prelistener() return false end
function AlertOnDetectListener:is_postlistener() return true end
function AlertOnDetectListener:compare(other, pre) return 0 end
function AlertOnDetectListener:process(game_ctx, local_ctx, networking, event)
  if local_ctx.id ~= 0 then return end

  local message = string.format('You noticed %s is here', event.adventurer_name)
  for _, detector in ipairs(event.detectors) do
    local detector_advn, detector_advn_ind = adventurers.get_by_name(game_ctx, detector)

    system_messages:send(game_ctx, local_ctx, networking, detector_advn_ind, message, 0)
  end
end

prototype.support(AlertOnDetectListener, 'listener')
return class.create('AlertOnDetectListener', AlertOnDetectListener)
