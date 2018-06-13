--- Describes something capable of parsing commands

local prototype = require('prototypes/prototype')

prototype.register('command', {
  --- Returns the priority of this command
  -- Valid priorities are 'listener', 'explicit', 'implicit', 'generic'
  -- @treturn string the priority of this command
  'priority',

  --- Parse the text that was entered to the console
  --
  -- A command should never perform any action directly; instead, it should
  -- return what events should be raised to handle the command.
  --
  -- @tparam GameContext game_ctx the game context
  -- @tparam LocalContext local_ctx the local context
  -- @tparam string text the text that the user entered
  -- @treturn boolean,{Event,...} if command handled, events raised
  'parse'
})
