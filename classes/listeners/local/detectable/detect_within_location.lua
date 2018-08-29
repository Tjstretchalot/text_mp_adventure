--- This listeners gives people in the same location as someone doing
-- something detectable an opportunity to detect them.
-- @classmod DetectinWithinLocationListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local adventurers = require('functional/game_context/adventurers')
-- endregion


local DetectinWithinLocationListener = {}

function DetectinWithinLocationListener:get_events() return { LocalDetectableEvent = true } end
function DetectinWithinLocationListener:is_prelistener() return true end
function DetectinWithinLocationListener:is_postlistener() return false end
function DetectinWithinLocationListener:compare(other, pre) return 0 end
function DetectinWithinLocationListener:process(game_ctx, local_ctx, networking, event)
  local advn_nm = event.adventurer_name

  local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)

  for _, loc in ipairs(advn.locations) do
    local oadvns = adventurers.get_by_location(game_ctx, loc)

    for _, oadvn in ipairs(oadvns) do
      if advn.name ~= oadvn.name then
        event:add_eligible_detector(oadvn.name, { DetectinWithinLocationListener = true })
      end
    end
  end
end

prototype.support(DetectinWithinLocationListener, 'listener')
return class.create('DetectinWithinLocationListener', DetectinWithinLocationListener)
