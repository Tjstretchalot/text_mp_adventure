--- This is for the /help command
-- This command issues the help event.
-- @classmod HelpCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/command')

local word_wrap = require('functional/word_wrap')
-- endregion

local HelpCommand = {}

function HelpCommand.priority() return 'explicit' end

function HelpCommand:parse(game_ctx, local_ctx, text)
  if text == '/help' then
    print('\n\27[1mHelp Menu\27[0m')
    word_wrap.print_wrapped(
      '/help - see this menu\n' ..
      '/look - look around your current location\n' ..
      '/move - move to a different location\n' ..
      '/specialization - learn about your specialization\n' ..
      '/start - start the game\n',
      2)
    local_ctx.dirty = true
    return true, {}
  end
  return false, nil
end

prototype.support(HelpCommand, 'command')
return class.create('HelpCommand', HelpCommand)
