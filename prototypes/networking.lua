--- Describes something which is able to handle networking

local prototype = require('prototypes/prototype')

prototype.register('networking', {
  --- Do anything that needs to be done networking-wise
  -- @tparam GameContext game_ctx the current game context
  -- @tparam LocalContext local_ctx the local context
  -- @tparam EventQueue event_queue the event queue
  'update',

  --- This is invoked when our client wishes to broadcast event(s)
  -- This function must ensure that this event is recieved in order
  -- for all connected clients, and is internally in order; the
  -- events occur in the order that this function is called and
  -- in the order provided by the array.
  -- @tparam GameContext game_ctx the current game context
  -- @tparam LocalContext local_ctx the local context
  -- @tparam {Event,...} events the events to broadcast
  'broadcast_events',

  --- This is invoked when we need to disconnect
  -- @tparam GameContext game_ctx the current game context
  -- @tparam LocalGontext local_ctx the local context
  -- @tparam EventQueue event_queue the event queue
  'disconnect'
})
