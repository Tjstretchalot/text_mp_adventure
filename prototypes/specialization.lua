--- Registers the specialization prototype

local prototype = require('prototypes/prototype')

prototype.register('specialization', {
  --- Get the name of this specialization
  -- @treturn string the name of the specialization
   'get_name',

   --- Get a brief description of the specialization
   -- @treturn string brief description of the specialization
   'get_short_description',

   --- Get a long description of the specialization. Do not manually word
   -- wrap and assume a base indentation of 0.
   -- @treturn string long description of the specialization.
   'get_long_description',

   --- Get the commands associated with this specialization.
   -- @treturn {SpecializationCommand,...} the commands for this spec
   'get_specialization_commands',

   --- Get any passive abilities associated with this specialization.
   -- Note that these aren't implemented here, they are just used for
   -- the help text.
   -- Additional passives should be added to the adventurer directly.
   -- @treturn {SpecializationPassive,...} the passives for this spec
   'get_specialization_passives',

   --- Decide the starting location for players with this specialization.
   -- Note that this will only be called server-side so using math.random
   -- is perfectly okay.
   -- @tparam GameContext game_ctx the game context
   -- @tparam LocalContext local_ctx the local context
   -- @treturn string the name of the location to start in 
   'get_random_starting_location'
})
