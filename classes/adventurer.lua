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
  -- locations is an array of strings so no special serialization is necessary
  return { name = self.name, locations = array.public_primitives_deep_copy(self.locations) }
end

function Adventurer.deserialize(serd)
  return Adventurer._wrapped_class:new(serd)
end

function Adventurer:context_changed(game_ctx)
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

--- Set the location of the adventurer to the new location,
-- replacing the old location if there is one.
-- @tparam string|{string,...} the location or locations to set it to
function Adventurer:replace_location(location)
  if not location then error('argument nil: location') end

  if type(location) == 'string' then
    self.locations = { location }
  else
    self.locations = {}
    for _,v in ipairs(location) do
      table.insert(self.locations, v)
    end
  end
end

prototype.support(Adventurer, 'serializable')
return class.create('Adventurer', Adventurer)
