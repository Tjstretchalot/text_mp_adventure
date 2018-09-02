--- Event alias for detection.send_to_detected_by. This callback is required
-- if you want to detect people and then send them a message, but you're stuck
-- inside a listener.
-- @classmod SendToDetectedByCallbackEvent


-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')

local adventurers = require('functional/game_context/adventurers')
local detection = require('functional/detection')
local system_messages = require('functional/system_messages')
-- endregion

local SendToDetectedByCallbackEvent = {}

simple_serializer.inject(SendToDetectedByCallbackEvent)

function SendToDetectedByCallbackEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error(string.format('expected adventurer name is string, got %s (type=%s)',
      tostring(self.adventurer_name), type(self.adventurer_name)), 3)
  end

  if type(self.message) ~= 'string' then
    error(string.format('expected message is string, got %s (type=%s)',
      tostring(self.message), type(self.message)), 3)
  end
end

function SendToDetectedByCallbackEvent:process(game_ctx, local_ctx, networking)
  if local_ctx.id ~= 0 then return end

  local advn, advn_ind = adventurers.get_by_name(game_ctx, self.adventurer_name)
  detection.send_to_detected_by(game_ctx, local_ctx, networking, advn.locations,
    self.message, self.adventurer_name, {})
end

prototype.support(SendToDetectedByCallbackEvent, 'event')
prototype.support(SendToDetectedByCallbackEvent, 'serializable')
return class.create('SendToDetectedByCallbackEvent', SendToDetectedByCallbackEvent)
