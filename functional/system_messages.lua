--- This module makes it easy to issue system messages. This should
-- only be called by the host, since that's the only one that can
-- generate system messages (otherwise you probably need to implement
-- whatever your doing as an event)
-- @module system_messages

local LocalSystemMessageEvent = require('classes/events/local/local_system_message')
local SystemMessageEvent = require('classes/events/system_message')

local adventurers = require('functional/game_context/adventurers')

local system_messages = {}

--- Try to send a message to the given adventurer. Can only be done on the host.
-- @tparam GameContext game_ctx the game context
-- @tparam LocalContext local_ctx the local context
-- @tparam number|string advn_ind_or_name the index or name of the recipient of the message
-- @tparam string text the system message to send
-- @tparam nil|number indent the indent for the message
function system_messages:send(game_ctx, local_ctx, networking, advn_ind_or_name, text, indent)
  if local_ctx.id ~= 0 then error('attempt to send system message on non-host', 2) end

  local advn_ind
  if type(advn_ind_or_name) == 'string' then
    local _, act_advn_ind = adventurers.get_by_name(game_ctx, advn_ind_or_name)
    advn_ind = act_advn_ind
  else
    advn_ind = advn_ind_or_name
  end

  local evnt = LocalSystemMessageEvent:new{ adventurer_ind = advn_ind, message = text, indent = indent }

  local_ctx.listener_processor:invoke_pre_listeners(game_ctx, local_ctx, nil, evnt)
  evnt:process(game_ctx, local_ctx)
  local_ctx.listener_processor:invoke_post_listeners(game_ctx, local_ctx, nil, evnt)

  if evnt.result then
    local advn_name = game_ctx.adventurers[evnt.adventurer_ind].name
    networking:broadcast_events(game_ctx, local_ctx, {
      SystemMessageEvent:new{ adventurer_name = advn_name, message = evnt.message, indent = evnt.indent }
    })
  end
end

return system_messages
