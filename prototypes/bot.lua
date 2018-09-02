--- Describes a bot, which is attached to a particular adventurer. A bot must
-- also be a 'listener' which is applied directly to the listener processor.
-- Bots must be serializable and do not need to be reattachable.

local prototype = require('prototypes/prototype')

prototype.register('bot', {
  --- Returns the name of the adventurer that this bot is managing.
  -- @treturn string name of the adventurer this bot manages.
  'get_adventurer_name'
})
