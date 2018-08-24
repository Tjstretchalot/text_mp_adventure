--- Restricts movements to locations with a connection to the current location.
-- Also uses that adjacency to determine the time it requires to get to the
-- destination.
-- @classmod MoveBetweenAccessibleListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')
-- endregion


local MoveBetweenAccessibleListener = {}

function MoveBetweenAccessibleListener:get_events() return { LocalMoveEvent = true } end
function MoveBetweenAccessibleListener:is_prelistener() return true end
function MoveBetweenAccessibleListener:is_postlistener() return false end
function MoveBetweenAccessibleListener:compare(other, pre) return 0 end
function MoveBetweenAccessibleListener:process(game_ctx, local_ctx, networking, event)
  if not event.result then return end

  local advn_ind = event.adventurer_ind
  local dest = event.destination

  local advn = game_ctx.adventurers[advn_ind]
  if not advn.locations then return end
  if #advn.locations < 1 then return end

  local world = game_ctx.world
  local adjacent = world:get_nearby(dest)

  for _,loc in ipairs(advn.locations) do
    for _,adj in ipairs(adjacent) do
      if loc == adj.location then
        event.time_ms = adj.time_ms
        return
      end
    end
  end

  event.fail_reason = 'No connection available'
  event.result = false
end

prototype.support(MoveBetweenAccessibleListener, 'listener')
return class.create('MoveBetweenAccessibleListener', MoveBetweenAccessibleListener)
