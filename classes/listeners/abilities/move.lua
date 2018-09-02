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
local DetectorEvent = require('classes/events/detector')
local MoveListenerPostAbilityCallbackEvent = require('classes/events/callbacks/move_listener_post_ability')

-- endregion

local MoveListener = {}

local send_to_detected_by = detection.send_to_detected_by

function MoveListener:get_listen_ability()
  return 'MoveEvent'
end

function MoveListener:post_ability_started(game_ctx, local_ctx, networking, event)
  local advn_nm = event.adventurer_name
  local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)
  local dest = event.ability.ability.serialized.destination
  system_messages:send(game_ctx, local_ctx, networking, advn_ind,
    string.format('Movement to %s started', dest), 0)

  networking:broadcast_events(game_ctx, local_ctx, {
    DetectableEvent:new{
      detectable_advn_nm = advn_nm,
      tags = { MoveListener = true }
    }
  })
  send_to_detected_by(game_ctx, local_ctx, networking, advn.locations,
    string.format('%s has started to leave toward %s.', advn_nm, dest),
    advn_nm)
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

  table.insert(events, MoveListenerPostAbilityCallbackEvent:new{
    adventurer_name = advn_nm,
    from = event.from
  })

  table.insert(events, DetectableEvent:new{
    detectable_advn_nm = advn_nm,
    tags = { MoveListener = true }
  })

  table.insert(events, DetectorEvent:new{
    detector_advn_nm = advn_nm,
    tags = {
      MoveListener = true
    }
  })

  networking:broadcast_events(game_ctx, local_ctx, events)
end


ability_listener_noops(MoveListener)
prototype.support(MoveListener, 'ability_listener')
return class.create('MoveListener', MoveListener)
