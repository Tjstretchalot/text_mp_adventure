--- This is for the /help command
-- This command issues the help event.
-- @classmod HelpCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/command')

local TalkEvent = require('classes/events/talk')
-- endregion

local HelpCommand = {}

function HelpCommand.priority() return 'explicit' end

function HelpCommand:parse(game_ctx, local_ctx, text)
  if text == '/help' then
    print('\n\27[1mHelp Menu\27[0m')
    print('  /adventurers - Work with adventurers')
    print('  /help - Show this menu')
    local_ctx.dirty = true
    return true, {}
  end
  return false, nil
end

prototype.support(HelpCommand, 'command')
return class.create('HelpCommand', HelpCommand)
