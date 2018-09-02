--- This is the event handling a /search command
-- @classmod SearchCommandEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')

local command_events = require('functional/command_events')

local AbilityEvent = require('classes/events/abilities/ability')

local DetectorEvent = require('classes/events/detector')
-- endregion

local DURATION = 1000 * 60 * 30
local SearchCommandEvent = {}

simple_serializer.inject(SearchCommandEvent)

function SearchCommandEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error('SearchCommandEvent is missing adventurer name (string)', 3)
  end
end

function SearchCommandEvent:process(game_ctx, local_ctx, networking)
  if local_ctx.id ~= 0 then return end

  local detector_evnt = DetectorEvent:new{detector_advn_nm = self.adventurer_name, tags = { SearchCommandEvent = true }}

  command_events.networked_set_ability(game_ctx, local_ctx, networking, self.adventurer_name, DURATION, detector_evnt)
end

prototype.support(SearchCommandEvent, 'event')
prototype.support(SearchCommandEvent, 'serializable')
return class.create('SearchCommandEvent', SearchCommandEvent)
