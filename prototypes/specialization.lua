--- Registers the specialization prototype

local prototype = require('prototypes/prototype')

prototype.register('specialization', {
  --- Get the name of this specialization
  -- @treturn string the name of the specialization
   'get_name',

   --- Get a brief description of the specialization
   -- @treturn string brief description of the specialization
   'get_description'
})
