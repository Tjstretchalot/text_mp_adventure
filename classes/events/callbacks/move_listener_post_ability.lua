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

local AdventurerEvent = require('classes/events/adventurer')
local SendToDetectedByCallbackEvent = require('classes/events/callbacks/send_to_detected_by')
-- endregion

local MoveListenerPostAbilityCallbackEvent = {}

simple_serializer.inject(MoveListenerPostAbilityCallbackEvent)

function MoveListenerPostAbilityCallbackEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error(string.format('expected adventurer name is string, got %s (type=%s)',
      tostring(self.adventurer_name), type(self.adventurer_name)), 3)
  end

  if type(self.from) ~= 'table' then
    error(string.format('expected from is table, but type=%s', type(self.from)))
  end
end

function MoveListenerPostAbilityCallbackEvent:process(game_ctx, local_ctx, networking)
  if local_ctx.id ~= 0 then return end

  local moved_advn_name = self.adventurer_name
  local moved_advn, moved_advn_ind = adventurers.get_by_name(game_ctx, moved_advn_name)

  local events = {}
  local completed_nms = {}
  for _, loc in ipairs(self.from) do
    local advns = adventurers.get_by_location(game_ctx, loc)

    for _, advn in ipairs(advns) do
      if not completed_nms[advn.name] then
        completed_nms[advn.name] = true

        if advn:is_detected(moved_advn_name) then
          table.insert(events, AdventurerEvent:new{
            type = 'remove_detect',
            adventurer_name = advn.name,
            detected_name = moved_advn_name
          })
        end
      end
    end
  end

  table.insert(events, AdventurerEvent:new{
    type = 'clear_detect',
    adventurer_name = moved_advn_name
  })

  table.insert(events, SendToDetectedByCallbackEvent:new{
    adventurer_name = self.adventurer_name,
    message = string.format('%s has arrived at your location.', self.adventurer_name)
  })

  networking:broadcast_events(game_ctx, local_ctx, events)

  system_messages:send(game_ctx, local_ctx, networking, moved_advn_ind,
    string.format('Movement to %s finished', moved_advn.locations[1]), 0)
end

prototype.support(MoveListenerPostAbilityCallbackEvent, 'event')
prototype.support(MoveListenerPostAbilityCallbackEvent, 'serializable')
return class.create('MoveListenerPostAbilityCallbackEvent', MoveListenerPostAbilityCallbackEvent)
