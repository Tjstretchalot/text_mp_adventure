--- Describes an active ability
-- All specialization commands have the 'explicit' priority. Due to this, they
-- also will always be of the slash-command style. They will be parsed allowing
-- quotes in their arguments.

local prototype = require('prototypes/prototype')

prototype.register('specialization_command', {
  --- Get the preferred way to call this command.
  -- For example, 'attack' return corresponds with slash command '/attack'
  -- @treturn string the preferred slash command without the slash
  'get_command',

  -- Get any valid aliases for this command.
  -- @return {string,...} aliases for this command.
  'get_aliases',

  --- Get the short help text, which is printed immediately after this slash
  -- command. This should not include technical details; for example,
  -- you might want the following display:
  -- '/attack location - attack the target location'
  -- This would be a return value of 'attack the target location'.
  -- @treturn string short help text
  'get_short_description',

  --- Get the longer help text, which is printed if 'parse' returns false
  -- or if the --help argument is given.
  -- This should include all necessary details for understanding this ability.
  -- This may use newlines but should not assume any indentation is necessary;
  -- if indentation is used for each line then it will be automatically added
  -- later. For example, a reasonable return value is:
  -- 'Attacks the target location:\n' ..
  -- '  If there are no humans in the location, then there is..' <omitted>
  -- 'Usage:\n' ..
  -- '  /attack location\n'
  -- '    location - the location name'
  -- 'Examples:\n' ..
  -- '  /attack Outskirts1'
  -- is perfectly reasonable, since the 'base' indentation is
  -- 0. Do not add newlines as a form of manual word-wrap. Usage always
  -- goes before examples which should come at the end or not at all.
  -- @treturn string long help text
  'get_long_description',

  --- Parse the text that was entered to the console. Return false, {} to get
  -- the help text displayed. The arguments will not include the slash command,
  -- but this won't be invoked unless it starts with either the command or an
  -- alias.
  --
  -- A command should never perform any action directly; instead, it should
  -- return what events should be raised to handle the command.
  --
  -- @tparam GameContext game_ctx the game context
  -- @tparam LocalContext local_ctx the local context
  -- @tparam {string,...} args the arguments (loaded from arg_parser)
  -- @treturn boolean,{Event,...} if command handled, events raised
  'parse'
})
