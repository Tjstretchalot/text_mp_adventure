--- Adds the players current location to the message
-- @classmod LocalLookEventCurrentLocation

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')
-- endregion

local LocalLookEventCurrentLocation = {}

local function pretty_light_level(game_ctx, light_level)
  if light_level == 'inside_dark' then return 'Darkness' end
  if light_level == 'inside_electricity' then return 'Brightly lit interior' end
  if light_level == 'outside' then
    if game_ctx.day.is_day then return 'Outside (day)' end
    return 'Outside (night)'
  end

  error('unknown light level: ' .. light_level, 2)
end

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
    local loc_nm = advn.locations[1]
    local loc = game_ctx.locations[loc_nm]
    event:append_line('You are at ' .. loc_nm .. ' | ' .. pretty_light_level(game_ctx, loc.lighting))
    event:append_indented_line(loc.description, 2)
  else
    event:append_line('You are in multiple locations:')
    for _,loc_nm in ipairs(advn.locations) do
      local loc = game_ctx.locations[loc_nm]
      event:append_indented_line(loc_nm .. ' | ' .. pretty_light_level(game_ctx, loc.lighting), 2)
      event:append_indented_line(loc.description, 4)
    end
  end
end

prototype.support(LocalLookEventCurrentLocation, 'listener')
return class.create('LocalLookEventCurrentLocation', LocalLookEventCurrentLocation)
