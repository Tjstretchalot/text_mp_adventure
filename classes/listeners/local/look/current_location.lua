--- Adds the players current location to the message
-- @classmod LocalLookEventCurrentLocation

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')
-- endregion


local LocalLookEventCurrentLocation = {}

function LocalLookEventCurrentLocation:get_events() return { LocalLookEvent = true } end
function LocalLookEventCurrentLocation:is_prelistener() return true end
function LocalLookEventCurrentLocation:is_postlistener() return false end
function LocalLookEventCurrentLocation:compare(other, pre) return 0 end
function LocalLookEventCurrentLocation:process(game_ctx, local_ctx, networking, event)
  if not event.result then return end

  local advn_ind = event.adventurer_ind

  local advn = game_ctx.adventurers[advn_ind]
  if not advn.locations then return end
  if #advn.locations < 1 then return end

  if #advn.locations == 1 then
    local loc = advn.locations[1]
    event:append_line('You are at ' .. loc)
    event:append_indented_line(game_ctx.locations[loc].description, 2)
  else
    event:append_line('You are in multiple locations:')
    for _,loc in ipairs(advn.locations) do
      event:append_indented_line(loc, 2)
      event:append_indented_line(game_ctx.locations[loc].description, 4)
    end
  end
end

prototype.support(LocalLookEventCurrentLocation, 'listener')
return class.create('LocalLookEventCurrentLocation', LocalLookEventCurrentLocation)
