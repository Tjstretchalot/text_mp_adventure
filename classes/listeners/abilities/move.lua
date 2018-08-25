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

local function send_msg_to_location(game_ctx, local_ctx, networking, locs, message, except_advn_ind)
  if type(locs) == 'string' then locs = { locs } end

  for _, loc in ipairs(locs) do
    local advns = adventurers.get_by_location(game_ctx, loc)

    for advn_ind, advn in ipairs(advns) do
      if advn_ind ~= except_advn_ind then
        system_messages:send(game_ctx, local_ctx, networking, advn_ind,
          message, 0)
      end
    end
  end
end

function MoveListener:get_listen_ability()
  return 'MoveEvent'
end

function MoveListener:post_ability_started(game_ctx, local_ctx, networking, event)
  local advn_nm = event.adventurer_name
  local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)
  local dest = event.ability.ability.serialized.destination
  system_messages:send(game_ctx, local_ctx, networking, advn_ind,
    string.format('Movement to %s started', dest), 0)

  send_msg_to_location(game_ctx, local_ctx, networking, advn.locations,
    string.format('%s has started to leave toward %s.', advn_nm, dest), advn_ind)
end

function MoveListener:ability_cancelled(game_ctx, local_ctx, networking, cancelled_event, event, pre)
  if not pre then
    local advn_nm = event.adventurer_name
    local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)
    system_messages:send(game_ctx, local_ctx, networking, advn_ind,
      string.format('Movement to %s cancelled', event.destination), 0)
    send_msg_to_location(game_ctx, local_ctx, networking, advn.locations,
      string.format('%s has stopped leaving.', advn_nm), advn_ind)
  end
end

function MoveListener:pre_ability(game_ctx, local_ctx, networking, event)
  local advn_nm = event.adventurer_name
  local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)
  send_msg_to_location(game_ctx, local_ctx, networking, advn.locations,
    string.format('%s has left toward %s.', advn_nm, event.destination), advn_ind)
end

function MoveListener:post_ability(game_ctx, local_ctx, networking, event)
  local advn_nm = event.adventurer_name
  local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)
  system_messages:send(game_ctx, local_ctx, networking, advn_ind,
    string.format('Movement to %s finished', event.destination), 0)

  send_msg_to_location(game_ctx, local_ctx, networking, advn.locations,
    string.format('%s has arrived.', advn_nm), advn_ind)
end


ability_listener_noops(MoveListener)
prototype.support(MoveListener, 'ability_listener')
return class.create('MoveListener', MoveListener)
