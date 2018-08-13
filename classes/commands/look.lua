--- Allows the player to determine where he is and where he can go
-- @classmod LookCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/command')

local adventurers = require('functional/game_context/adventurers')

local LookEvent = require('classes/events/look')
-- endregion

local LookCommand = {}

function LookCommand.priority() return 'explicit' end

function LookCommand:parse(game_ctx, local_ctx, text)
  if game_ctx.in_setup_phase then return end

  if text == '/look' then
    local loc_advn_nm = adventurers.get_local_name(game_ctx, local_ctx)

    return true, { LookEvent:new{ adventurer_name = loc_advn_nm } }
  end

  return false, nil
end

prototype.support(LookCommand, 'command')
return class.create('LookCommand', LookCommand)
