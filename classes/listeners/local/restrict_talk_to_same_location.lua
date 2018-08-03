--- This listener restricts talking to people within the same location
-- @classmod RestrictTalkToSameLocationListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local adventurers = require('functional/game_context/adventurers')
local locations = require('functional/game_context/locations')
-- endregion


local RestrictTalkToSameLocationListener = {}

function RestrictTalkToSameLocationListener:get_events() return { CommunicationEvent = true } end
function RestrictTalkToSameLocationListener:is_prelistener() return false end
function RestrictTalkToSameLocationListener:is_postlistener() return true end
function RestrictTalkToSameLocationListener:compare(other, pre) return 0 end
function RestrictTalkToSameLocationListener:process(game_ctx, local_ctx, networking, event)
  local from_advn = adventurers.get_adventurer(game_ctx, event.from_id)
  local to_advn = adventurers.get_adventurer(game_ctx, event.to_id)

  for _, from_loc in ipairs(from_advn.locations) do
    for _, to_loc in ipairs(to_advn.locations) do
      if from_loc == to_loc then return end
    end
  end

  event.result = false
end

prototype.support(RestrictTalkToSameLocationListener, 'listener')
return class.create('RestrictTalkToSameLocationListener', RestrictTalkToSameLocationListener)
