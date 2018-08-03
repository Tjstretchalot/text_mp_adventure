--- The communication helper library makes it easier to determine
-- if two players can communicate.
-- @module communication

local adventurers = require('functional/game_context/adventurers')
local locations = require('functional/game_context/locations')

local CommunicationEvent = require('classes/events/local/communication')

local communication = {}

--- Determine if the local player can hear the given adventurer
-- @tparam GameContext game_ctx the state of the game
-- @tparam LocalContext local_ctx the local state
-- @tparam number adv_id the id of the adventurer we want to hear
function communication.local_can_hear(game_ctx, local_ctx, adv_id)
  local local_advn = adventurers.get_local_adventurer(game_ctx, local_ctx)
  if not local_advn then return false end

  local evnt = CommunicationEvent:new({
    from_id = local_advn.id,
    to_id = adv_id
  })

  local_ctx.listener_processor:invoke_pre_listeners(game_ctx, local_ctx, nil, evnt)
  evnt:process(game_ctx, local_ctx)
  local_ctx.listener_processor:invoke_post_listeners(game_ctx, local_ctx, nil, evnt)

  return evnt.result  
end
