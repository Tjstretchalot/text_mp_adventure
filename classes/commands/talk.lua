--- This command simply outputs to the screen
-- This works through the TalkEvent
-- @classmod TalkCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/command')

local TalkEvent = require('classes/events/talk')
-- endregion

local TalkCommand = {}

function TalkCommand.priority() return 'generic' end

function TalkCommand:parse(game_ctx, local_ctx, text)
  return true, { TalkEvent:new{message = text, id = local_ctx.id} }
end

prototype.support(TalkCommand, 'command')
return class.create('TalkCommand', TalkCommand)
