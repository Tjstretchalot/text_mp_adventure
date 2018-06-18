--- This event can be listened for by other listeners for detecting
-- day or night cycles.
-- @module DayNightCycleEvent
-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
-- endregion

local DayNightCycleEvent = {}

simple_serializer.inject(DayNightCycleEvent)

function DayNightCycleEvent:init()
  if type(self.is_day) ~= 'boolean' then
    error('Day night cycles should have is_day set as a boolean', 3)
  end
end

function DayNightCycleEvent:process(game_ctx, local_ctx)
end

prototype.support(DayNightCycleEvent, 'event')
prototype.support(DayNightCycleEvent, 'serializable')
return class.create('DayNightCycleEvent', DayNightCycleEvent)
