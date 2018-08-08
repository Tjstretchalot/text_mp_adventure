--- A test specializaton command
-- @classmod TestSpecializationCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/specialization_command')
-- endregion

local TestSpecializationCommand = {}

function TestSpecializationCommand:get_command()
  return 'test'
end

function TestSpecializationCommand:get_aliases()
  return { 'ping' }
end

function TestSpecializationCommand:get_short_description()
  return 'print pong'
end

function TestSpecializationCommand:get_long_description()
  return ('here is a really long desciption of the extremely elaborate pong'
    .. ' command which just prints out pong')
end

function TestSpecializationCommand:parse(game_ctx, local_ctx, args)
  print('\27[K\rpong')
  return true, {}
end


prototype.support(TestSpecializationCommand, 'specialization_command')
return class.create('TestSpecializationCommand', TestSpecializationCommand)
