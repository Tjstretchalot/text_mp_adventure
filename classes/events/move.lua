--- Handles the moving of an adventurer as a result /move command.
-- This is the final result of the command
-- @classmod MoveEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')

local adventurers = require('functional/game_context/adventurers')
-- endregion

local MoveEvent = {}

simple_serializer.inject(MoveEvent)

function MoveEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error('MoveEvent is missing adventurer name (string)', 3)
  end

  if type(self.destination) ~= 'string' then
    error('MoveEvent is missing destination (string)', 3)
  end
end

function MoveEvent:process(game_ctx, local_ctx, networking)
  local loc = game_ctx.locations[self.destination]
  if not loc then error('Bad location ' .. tostring(self.destination)) end

  local advn, adventurer_ind = adventurers.get_by_name(game_ctx, self.adventurer_name)

  self.from = {}
  for k,v in ipairs(advn.locations) do
    self.from[k] = v
  end
  
  advn:replace_location(self.destination)
end

prototype.support(MoveEvent, 'event')
prototype.support(MoveEvent, 'serializable')
return class.create('MoveEvent', MoveEvent)
