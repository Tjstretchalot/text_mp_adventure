--- Starts the game
-- @classmod StartGameCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/command')

local StartGameEvent = require('classes/events/start_game')
-- endregion

local StartGameCommand = {}

function StartGameCommand.priority() return 'explicit' end

function StartGameCommand:parse(game_ctx, local_ctx, text)
  if text ~= '/start' then return false, nil end
  if local_ctx.id ~= 0 then
    print('\r/start\nOnly the host can do that.')
    return true, {}
  end

  return true, { StartGameEvent:new() }
end

prototype.support(StartGameCommand, 'command')
return class.create('StartGameCommand', StartGameCommand)
