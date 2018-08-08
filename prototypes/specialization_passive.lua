--- Describes a passive ability for a specialization
-- This does not actually *implement* the passive, which should be done
-- via a listener. It merely adds it to the help text.

local prototype = require('prototypes/prototype')

prototype.register('specialization_passive', {
  --- Get the name for this passive.
  -- @treturn string the name of the specialization
   'get_name',

   --- Get a brief description of the passive. Do not include *Passive*.
   -- Assume the name has already been shown, followed by *Passive*. Ex:
   -- return 'gets attacked first' to get something like:
   -- 'Aware: *Passive* gets attacked first'. Capitilization of the first
   -- letter will be determined by the displaying party and it does not matter
   -- what you return.
   -- @treturn string brief description of the specialization passive
   'get_short_description',

   --- Get a long description of the passive. Do not manually word wrap and
   -- assume a base indentation of 0. Assume the name is already displayed.
   -- Do not include *Passive*. Assume *Passive* or similiar starts the description
   -- @treturn string long description of the passive.
   'get_long_description',
})
