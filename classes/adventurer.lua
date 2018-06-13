--- Describes an adventurer, which is someone played by a
-- person. Implements serializable
--
-- @classmod Adventurer

local class = require('classes/class')
local prototype = require('prototypes/prototype')
require('prototypes/serializable')

local Adventurer = {}

-- region serializable
function Adventurer:serialize()
  return { name = self.name }
end

function Adventurer.deserialize(serd)
  return Adventurer:new(serd)
end

function Adventurer:context_changed(game_ctx) end
-- endregion

function Adventurer:init()
  if type(self.name) ~= 'string' then
    error('Adventurers require names!', 3)
  end
end

function Adventurer:greet()
  print('Hello! I am called ' .. tostring(self.name))
end

prototype.support(Adventurer, 'serializable')
return class.create('Adventurer', Adventurer)
