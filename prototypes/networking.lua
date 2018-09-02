--- Describes something which is able to handle networking
-- Due to the strong interdependency between the event queue
-- and networking, networking must also manage the event queue.

local prototype = require('prototypes/prototype')

prototype.register('networking', {
  --- Do anything that needs to be done networking-wise. This
  -- should also process the event queue!
  -- @tparam GameContext game_ctx the current game context
  -- @tparam LocalContext local_ctx the local context
  'update',

  --- This is invoked when our client wishes to broadcast event(s)
  -- This function must ensure that this event is recieved in order
  -- for all connected clients, and is internally in order; the
  -- events occur in the order that this function is called and
  -- in the order provided by the array.
  --
  -- This may NEVER process events!
  --
  -- @tparam GameContext game_ctx the current game context
  -- @tparam LocalContext local_ctx the local context
  -- @tparam {Event,...} events the events to broadcast
  'broadcast_events',

  --- This is invoked when we need to disconnect
  -- @tparam GameContext game_ctx the current game context
  -- @tparam LocalGontext local_ctx the local context
  'disconnect'
})
