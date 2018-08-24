--- Describes an ability event. Ability events should also support 'event'

local prototype = require('prototypes/prototype')

prototype.register('ability_event', {
  --- Set the name of the adventurer who caused this event.
  --
  -- @tparam adventurer_name the new adventurer name for this event
  'set_source_adventurer_name'
})
