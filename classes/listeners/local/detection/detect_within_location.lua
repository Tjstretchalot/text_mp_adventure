--- This listeners gives people in the same location as someone doing
-- something detectable an opportunity to detect them.
-- @classmod DetectWithinLocationListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local adventurers = require('functional/game_context/adventurers')
-- endregion


local DetectWithinLocationListener = {}

function DetectWithinLocationListener:get_events() return { LocalDetectableEvent = true, LocalDetectorEvent = true } end
function DetectWithinLocationListener:is_prelistener() return true end
function DetectWithinLocationListener:is_postlistener() return false end
function DetectWithinLocationListener:compare(other, pre) return 0 end
function DetectWithinLocationListener:process(game_ctx, local_ctx, networking, event)
  local is_detector = event.class_name == 'LocalDetectorEvent'
  local advn_nm = event.adventurer_name

  local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)

  for _, loc in ipairs(advn.locations) do
    local oadvns = adventurers.get_by_location(game_ctx, loc)

    for _, oadvn in ipairs(oadvns) do
      if advn.name ~= oadvn.name then
        if is_detector then
          event:add_eligible_detectable(oadvn.name, { DetectWithinLocationListener = true })
        else
          event:add_eligible_detector(oadvn.name, { DetectWithinLocationListener = true })
        end
      end
    end
  end
end

prototype.support(DetectWithinLocationListener, 'listener')
return class.create('DetectWithinLocationListener', DetectWithinLocationListener)
