--- Adds nearby locations to the message
-- @classmod LocalLookEventNearbyLocations

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')
-- endregion


local LocalLookEventNearbyLocations = {}

function LocalLookEventNearbyLocations:get_events() return { LocalLookEvent = true } end
function LocalLookEventNearbyLocations:is_prelistener() return true end
function LocalLookEventNearbyLocations:is_postlistener() return false end
function LocalLookEventNearbyLocations:compare(other, pre)
  if other == 'LocalLookEventCurrentLocation' then return 1
  elseif other == 'LocalLookEventPeopleInLocation' then return 1 end

  return 0
end
function LocalLookEventNearbyLocations:process(game_ctx, local_ctx, networking, event)
  if not event.result then return end

  local advn_ind = event.adventurer_ind

  local advn = game_ctx.adventurers[advn_ind]
  if not advn.locations then return end

  for _, loc in ipairs(advn.locations) do
    event:append_line('Nearby locations from ' .. loc .. ':')

    local nearby = game_ctx.world:get_nearby(loc)
    for _, nearby_loc in ipairs(nearby) do
      event:append_indented_line(nearby_loc.location .. ' (travel time: ' .. nearby_loc.time_ms  .. 'ms)', 2)
    end
  end
end

prototype.support(LocalLookEventNearbyLocations, 'listener')
return class.create('LocalLookEventNearbyLocations', LocalLookEventNearbyLocations)
