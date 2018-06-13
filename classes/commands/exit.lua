--- This is for the /exit command
-- This command issues the exit event.
-- @classmod ExitCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/command')

local ExitEvent = require('classes/events/exit')
local TalkEvent = require('classes/events/talk')
-- endregion

local ExitCommand = {}

function ExitCommand.priority() return 'explicit' end

function ExitCommand:parse(game_ctx, local_ctx, text)
  if text == '/exit' then
    return true, { TalkEvent:new{message = text, id = local_ctx.id}, ExitEvent:new{id = local_ctx.id} }
  end
  return false, nil
end

prototype.support(ExitCommand, 'command')
return class.create('ExitCommand', ExitCommand)
