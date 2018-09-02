--- This is the specialization for non-player characters who have not been
-- trained yet.
-- @classmod NPCSpecialization

-- region imports
local prototype = require('prototypes/prototype')
local class = require('classes/class')

require('prototypes/specialization')
-- endregion

local NPCSpecialization = {
  _commands = {},
  _passives = {}
}

function NPCSpecialization:get_name()
  return 'NPC'
end

function NPCSpecialization:get_short_description()
  return 'a non-player character'
end

function NPCSpecialization:get_long_description()
  return ('A character in the world with no special abilities that is controlled '
    .. 'automatically. They can be trained by officers and deputies into recruits '
    .. 'in order to achieve the human victory condition.')
end

function NPCSpecialization:get_specialization_commands()
  return self._commands
end

function NPCSpecialization:get_specialization_passives()
  return self._passives
end

function NPCSpecialization:get_random_starting_location()
  return 'open_market'
end

prototype.support(NPCSpecialization, 'specialization')
return class.create('NPCSpecialization', NPCSpecialization)
