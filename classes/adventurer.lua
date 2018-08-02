--- Describes an adventurer, which is someone played by a
-- person. Implements serializable
--
-- @classmod Adventurer

local class = require('classes/class')
local prototype = require('prototypes/prototype')

local array = require('functional/array')

require('prototypes/serializable')

local Adventurer = {}

-- region serializable
function Adventurer:serialize()
  return { name = self.name, locations = array.public_primitives_deep_copy(self.locations) }
end

function Adventurer.deserialize(serd)
  return Adventurer._wrapped_class:new(serd)
end

function Adventurer:context_changed(game_ctx)
  local fixed_locs = {}
  for k, loc in ipairs(self.locations) do
    fixed_locs[k] = game_ctx.locations[loc.name]
  end
  self.locations = fixed_locs
end
-- endregion

function Adventurer:init()
  if type(self.name) ~= 'string' then
    error('Adventurers require names!', 3)
  end

  if self.locations == nil then
    self.locations = {}
  end
end

function Adventurer:greet()
  print('Hello! I am called ' .. tostring(self.name))
end

prototype.support(Adventurer, 'serializable')
return class.create('Adventurer', Adventurer)
