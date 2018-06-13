--- Describes an event that can be processed

local prototype = require('prototypes/prototype')

prototype.register('event', {
  --- Process this event and apply it to the game world
  --
  -- @tparam GameContext the state of the game
  -- @tparam LocalContext the local context
  'process'
})
