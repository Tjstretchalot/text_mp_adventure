--- Describes the passing of real time to be simulated
-- Only the server sends time events, and the granularity is pretty low
-- This event merely tracks the time in the game_ctx.time_ms parameter
-- @classmod TimeEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
-- endregion

local TimeEvent = {}

simple_serializer.inject(TimeEvent)

function TimeEvent:init()
  if not self.ms then
    error('TimeEvents should be passed number of milliseconds as a number', 3)
  end
end

function TimeEvent:process(game_ctx, local_ctx)
  game_ctx.time_ms = (game_ctx.time_ms or 0) + self.ms
end

prototype.support(TimeEvent, 'event')
prototype.support(TimeEvent, 'serializable')
return class.create('TimeEvent', TimeEvent)
