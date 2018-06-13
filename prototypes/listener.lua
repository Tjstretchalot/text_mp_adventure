--- Describes something which listens for other events

local prototype = require('prototypes/prototype')

prototype.register('listener', {
  --- Returns a set of all the events this listener listens to
  -- May instead return the string '*' to listen to all events
  -- @treturn {string = boolean,...} class names of events this listens to
  'get_events',

  --- Returns if this listeners before the events are invoked
  -- @treturn boolean true if handles before the events, false otherwise
  'is_prelistener',

  --- Returns if this listens after the events are invoked
  -- @treturn boolean true if handles after the events, false otherwise
  'is_postlistener',

  --- Process an event that just occurred or is about to occur
  --
  -- @tparam GameContext game_ctx the state of the game
  -- @tparam LocalContext local_ctx the local context
  -- @tparam Networking networking the networking
  -- @tparam Event event the event that either just or is about to occur
  -- @tparam boolean pre true if we're before the event, false otherwise
  'process'
})
