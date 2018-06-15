--- Describes a location
-- @classmod Location

local class = require('classes/class')
local prototype = require('prototypes/prototype')
require('prototypes/serializable')

local Location = {}

-- region serializable
function Location:serialize()
  return { name = self.name, description = self.description }
end

function Location.deserialize(serd)
  return Location._wrapped_class:new(serd)
end

function Location:context_changed(game_ctx) end
-- endregion

function Location:init()
  if type(self.name) ~= 'string' then
    error('Locations require names!', 3)
  end

  if type(self.description) ~= 'string' then
    error('Locations require descriptions!', 3)
  end
end

prototype.support(Location, 'serializable')
return class.create('Location', Location)
