--- This is the main listener for /move
-- @classmod MoveListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

require('prototypes/ability_listener')

local ability_listener_noops = require('functional/ability_listener_noops')
local adventurers = require('functional/game_context/adventurers')
local array = require('functional/array')
local detection = require('functional/detection')
local system_messages = require('functional/system_messages')

local AdventurerEvent = require('classes/events/adventurer')
local DetectableEvent = require('classes/events/detectable')
local MoveListenerPostAbilityCallbackEvent = require('classes/events/callbacks/move_listener_post_ability')
local WrappedEvent = require('classes/events/wrapped')

-- endregion

local MoveListener = {}

--- Adventurers in the given location who have detected the given adventurer
-- AND are not the given adventurer are sent the given message.
--
-- @tparam GameContext game_ctx game context
-- @tparam LocalContext local_ctx local context
-- @tparam Networking networking networking
-- @tparam string|{string,...} location names
-- @tparam string message the message to send
-- @tparam string advn_nm the adventurer who we arent sending to and must be detected
-- @tparam {string,...} add_detected additional detected people by advn_nm
function MoveListener.send_to_detected_by(game_ctx, local_ctx, networking, locs, message, advn_nm, add_detected)
  if type(locs) == 'string' then locs = { locs } end

  for _, loc in ipairs(locs) do
    local advns = adventurers.get_by_location(game_ctx, loc)

    for advn_ind, advn in ipairs(advns) do
      local detected = advn:is_detected(advn_nm) or array.contains(add_detected, advn.name)

      if advn.name ~= advn_nm and detected then
        system_messages:send(game_ctx, local_ctx, networking, advn_ind,
          message, 0)
      end
    end
  end
end

local send_to_detected_by = MoveListener.send_to_detected_by

function MoveListener:get_listen_ability()
  return 'MoveEvent'
end

function MoveListener:post_ability_started(game_ctx, local_ctx, networking, event)
  local advn_nm = event.adventurer_name
  local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)
  local dest = event.ability.ability.serialized.destination
  system_messages:send(game_ctx, local_ctx, networking, advn_ind,
    string.format('Movement to %s started', dest), 0)

  local detectors = detection.determine_and_network_detection(game_ctx, local_ctx, networking, advn_nm, { move = true })
  send_to_detected_by(game_ctx, local_ctx, networking, advn.locations,
    string.format('%s has started to leave toward %s.', advn_nm, dest),
    advn_nm, detectors)
end

function MoveListener:ability_cancelled(game_ctx, local_ctx, networking, cancelled_event, event, pre)
  if not pre then
    local advn_nm = event.adventurer_name
    local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)
    system_messages:send(game_ctx, local_ctx, networking, advn_ind,
      string.format('Movement to %s cancelled', event.destination), 0)
    send_to_detected_by(game_ctx, local_ctx, networking, advn.locations,
      string.format('%s has stopped leaving.', advn_nm), advn_nm, {})
  end
end

function MoveListener:pre_ability(game_ctx, local_ctx, networking, event)
  local advn_nm = event.adventurer_name
  local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)
  send_to_detected_by(game_ctx, local_ctx, networking, advn.locations,
    string.format('%s has left toward %s.', advn_nm, event.destination), advn_nm, {})
end

function MoveListener:post_ability(game_ctx, local_ctx, networking, event)
  local advn_nm = event.adventurer_name
  local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)

  local events = {}
  local completed_nms = {}
  for _, loc in ipairs(event.from) do
    local advns = adventurers.get_by_location(game_ctx, loc)

    for _, advn in ipairs(advns) do
      if not completed_nms[advn.name] then
        completed_nms[advn.name] = true

        if advn:is_detected(advn_nm) then
          table.insert(events, AdventurerEvent:new{
            type = 'remove_detect',
            adventurer_name = advn.name,
            detected_name = advn_nm
          })
        end
      end
    end
  end

  table.insert(events, DetectableEvent:new{
    detectable_advn_nm = advn_nm,
    tags = { move = true }
  })

  table.insert(events, WrappedEvent:new{
      callback_event = MoveListenerPostAbilityCallbackEvent:new{
        adventurer_name = advn_nm
      }
  })

  networking:broadcast_events(game_ctx, local_ctx, events)
end


ability_listener_noops(MoveListener)
prototype.support(MoveListener, 'ability_listener')
return class.create('MoveListener', MoveListener)
