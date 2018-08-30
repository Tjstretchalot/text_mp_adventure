--- Get the current time of day
-- @classmod TimeCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/command')

local GetTimeEvent = require('classes/events/get_time')
-- endregion

local TimeCommand = {}

function TimeCommand.priority() return 'explicit' end

function TimeCommand:parse(game_ctx, local_ctx, text)
  if text ~= '/time' then return false, nil end

  return true, { GetTimeEvent:new{player_id = local_ctx.id} }
end

prototype.support(TimeCommand, 'command')
return class.create('TimeCommand', TimeCommand)
