--- This event is invoked when the host has started the round.
-- @classmod StartGameEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
local word_wrap = require('functional/word_wrap')
local spec_assigner = require('functional/specialization_assigner')
local spec_pool = require('classes/specializations/specialization_pool')

local AdventurerEvent = require('classes/events/adventurer')
local LocationEvent = require('classes/events/location')

local World = require('classes/world/world')
-- endregion

local StartGameEvent = {}

simple_serializer.inject(StartGameEvent)

function StartGameEvent:init()
end

function StartGameEvent:process(game_ctx, local_ctx)
  io.write('\27[2K\r=====\27[4mGame Started\27[9m=====')

  word_wrap.reload_console_width()
  game_ctx.in_setup_phase = false
  game_ctx.time_ms = 0
  game_ctx.day = true
  if local_ctx.id ~= 0 then return end
end

prototype.support(StartGameEvent, 'event')
prototype.support(StartGameEvent, 'serializable')
return class.create('StartGameEvent', StartGameEvent)
