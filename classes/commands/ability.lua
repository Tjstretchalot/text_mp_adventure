--- This is a local command to check how much time is left on your current ability
-- @classmod AbilityCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/command')

local adventurers = require('functional/game_context/adventurers')
local game_time = require('functional/game_time')
-- endregion

local AbilityCommand = {}

function AbilityCommand.priority() return 'explicit' end

function AbilityCommand:parse(game_ctx, local_ctx, text)
  if text ~= '/ability' then return false, nil end
  print('\r' .. text)

  local advn, advn_ind = adventurers.get_local_adventurer(game_ctx, local_ctx)
  if not advn then
    print('You aren\'t attached to an adventurer.')
    return true, {}
  end

  if not advn.active_ability then
    print('You aren\'t currently doing anything.')
    return true, {}
  end

  local dur = advn.active_ability.duration
  local pretty = game_time.pretty_elapsed(dur)

  print('You have ' .. pretty .. ' left on your ' .. advn.active_ability.ability.class_name)
  return true, {}
end

prototype.support(AbilityCommand, 'command')
return class.create('AbilityCommand', AbilityCommand)
