--- This is the main listener for /move
-- @classmod MoveListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

require('prototypes/ability_listener')

local adventurers = require('functional/game_context/adventurers')
local system_messages = require('functional/system_messages')
local ability_listener_noops = require('functional/ability_listener_noops')
-- endregion

local MoveListener = {}

function MoveListener:get_listen_ability()
  return 'MoveEvent'
end

function MoveListener:post_ability_started(game_ctx, local_ctx, networking, event)
  local advn_nm = event.adventurer_name
  local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)
  system_messages:send(game_ctx, local_ctx, networking, advn_ind,
    string.format('Movement to %s started', event.ability.ability.serialized.destination), 0)
end

function MoveListener:ability_cancelled(game_ctx, local_ctx, networking, cancelled_event, event, pre)
  if not pre then
    local advn_nm = event.adventurer_name
    local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)
    system_messages:send(game_ctx, local_ctx, networking, advn_ind,
      string.format('Movement to %s cancelled', event.destination), 0)
  end
end

function MoveListener:post_ability(game_ctx, local_ctx, networking, event)
  local advn_nm = event.adventurer_name
  local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)
  system_messages:send(game_ctx, local_ctx, networking, advn_ind,
    string.format('Movement to %s finished', event.destination), 0)
end


ability_listener_noops(MoveListener)
prototype.support(MoveListener, 'ability_listener')
return class.create('MoveListener', MoveListener)
