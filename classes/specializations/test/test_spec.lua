--- This specialization is only used for testing purposes
-- @classmod TestSpecialization

-- region imports
local prototype = require('prototypes/prototype')
local class = require('classes/class')

require('prototypes/specialization')

local TestSpecializationCommand = require('classes/specializations/test/test_command')
-- endregion

local TestSpecialization = {
  _commands = { TestSpecializationCommand },
  _passives = {}
}

function TestSpecialization:get_name()
  return 'Test'
end

function TestSpecialization:get_short_description()
  return 'a specialization for testing purposes'
end

function TestSpecialization:get_long_description()
  return ('Here is a really long line that I am going to utilize to make sure '
   .. 'that the wordwrapping methods are working correctly for really long '
   .. 'lines. This line probably will take 3 lines at least. Of course that '
   .. 'requires quite a long line.\n'
   .. '  I just forced a newline + an extra indent\n'
   .. 'I did it again. Now I am going to require just one injected newline '
   .. 'somewhere around here. So here we go making another long line')
end

function TestSpecialization:get_specialization_commands()
  return self._commands
end

function TestSpecialization:get_specialization_passives()
  return self._passives
end

prototype.support(TestSpecialization, 'specialization')
return class.create('TestSpecialization', TestSpecialization)
