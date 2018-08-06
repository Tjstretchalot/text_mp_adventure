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
  if not local_ctx.id then return false, {} end
  local loc_advn_id = game_ctx.adventurers_by_id[local_ctx.id]
  if not loc_advn_id then return false, {} end

  return true, { TalkEvent:new{message = text, name = game_ctx.adventurers[loc_advn_id].name} }
end

prototype.support(TalkCommand, 'command')
return class.create('TalkCommand', TalkCommand)
