--- This callback is required for the movelistener to know who
-- detected the adventurer when it arrived.
-- @classmod MoveListenerPostAbilityCallbackEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')

local adventurers = require('functional/game_context/adventurers')
local detection = require('functional/detection')
local system_messages = require('functional/system_messages')

local MoveListener -- to avoid circular dependency this is lazy inited
-- endregion

local MoveListenerPostAbilityCallbackEvent = {}

simple_serializer.inject(MoveListenerPostAbilityCallbackEvent)

function MoveListenerPostAbilityCallbackEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error(string.format('expected adventurer name is string, got %s (type=%s)',
      tostring(self.adventurer_name), type(self.adventurer_name)), 3)
  end
end

function MoveListenerPostAbilityCallbackEvent:process(game_ctx, local_ctx, networking)
  if local_ctx.id ~= 0 then return end

  if not MoveListener then
    MoveListener = require('classes/listeners/abilities/move')
  end

  local advn, advn_ind = adventurers.get_by_name(game_ctx, self.adventurer_name)

  system_messages:send(game_ctx, local_ctx, networking, advn_ind,
    string.format('Movement to %s finished', advn.locations[1]), 0)
  MoveListener.send_to_detected_by(game_ctx, local_ctx, networking, advn.locations,
    string.format('%s has arrived at your location.', self.adventurer_name),
    self.adventurer_name, {})
end

prototype.support(MoveListenerPostAbilityCallbackEvent, 'event')
prototype.support(MoveListenerPostAbilityCallbackEvent, 'serializable')
return class.create('MoveListenerPostAbilityCallbackEvent', MoveListenerPostAbilityCallbackEvent)
