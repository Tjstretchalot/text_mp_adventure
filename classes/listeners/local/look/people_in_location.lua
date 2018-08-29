--- Adds the other people in the players location to the message
-- @classmod LocalLookEventPeopleInLocation

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local adventurers = require('functional/game_context/adventurers')
-- endregion


local LocalLookEventPeopleInLocation = {}

function LocalLookEventPeopleInLocation:get_events() return { LocalLookEvent = true } end
function LocalLookEventPeopleInLocation:is_prelistener() return true end
function LocalLookEventPeopleInLocation:is_postlistener() return false end
function LocalLookEventPeopleInLocation:compare(other, pre)
  if other == 'LocalLookEventCurrentLocation' then return 1 end

  return 0
end

function LocalLookEventPeopleInLocation:process(game_ctx, local_ctx, networking, event)
  if not event.result then return end
  -- todo detection callbacks

  local advn_ind = event.adventurer_ind
  local advn = game_ctx.adventurers[advn_ind]

  for _, loc in ipairs(advn.locations) do
    event:append_line('People at ' .. loc .. ':')
    local ppl = adventurers.get_by_location(game_ctx, loc)
    for _, oadvn in ipairs(ppl) do
      if oadvn.name == advn.name or advn:is_detected(oadvn.name) then
        event:append_indented_line(oadvn.name, 2)
      end
    end
  end
end

prototype.support(LocalLookEventPeopleInLocation, 'listener')
return class.create('LocalLookEventPeopleInLocation', LocalLookEventPeopleInLocation)
