--- An event that modifies the location table
-- @classmod LocationEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

local Location = require('classes/location')
local locations = require('functional/game_context/locations')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
-- endregion

local LocationEvent = {}

simple_serializer.inject(LocationEvent)

function LocationEvent:init()
  if not self.type then
    error('Location events require a type', 3)
  end

  if self.type == 'new' then
    if type(self.location) ~= 'table' then
      error('New location events require a table to pass to the location constructor!', 3)
    end
  else
    error('Unknown location event type: ' .. self.type)
  end
end

function LocationEvent:process(game_ctx, local_ctx)
  if self.type == 'new' then
    locations.add_location(game_ctx, Location:new(self.location))
  else
    error('Unknown location event type ' .. self.type)
  end
end

prototype.support(LocationEvent, 'event')
prototype.support(LocationEvent, 'serializable')
return class.create('LocationEvent', LocationEvent)
