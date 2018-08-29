--- Adventurers may or may not know about everyones location. This module
-- makes it easier to automatically handle potential "detection events", which
-- are situations where an adventurer does something that would alert other
-- adventurers.
--
-- @module detection

local LocalDetectableEvent = require('classes/events/local/local_detectable')
local AdventurerEvent = require('classes/events/adventurer')

local detection = {}

--- Runs a LocalDetectableEvent in order to determine who detects the
-- detectable adventurer. Requires some tags for the event that the
-- adventurer is performing (typically the class name of the event that
-- calls this)
--
-- Returns the detectors table of the the event.
--
-- @tparam GameContext game_ctx the game context
-- @tparam LocalContext local_ctx the local context
-- @tparam Networking networking the networking
-- @tparam string detectable_advn_nm who did the detectable thing
-- @tparam {string=true,...} the tags for what the detectable guy did
-- @treturn {string,...} the names of the adventurers that detected the adventurer
function detection.local_determine_detection(game_ctx, local_ctx, networking, detectable_advn_nm, tags)
  local evnt = LocalDetectableEvent:new{
    adventurer_name = detectable_advn_nm,
    tags = tags
  }

  local_ctx.listener_processor:invoke_pre_listeners(game_ctx, local_ctx, networking, evnt)
  evnt:process(game_ctx, local_ctx, networking)
  local_ctx.listener_processor:invoke_post_listeners(game_ctx, local_ctx, networking, evnt)

  return evnt.detectors
end

--- Determine who detected the adventurer doing a thing, then network it through
-- AdventurerEvents.
--
-- @tparam GameContext game_ctx the game context
-- @tparam LocalContext local_ctx the local context
-- @tparam Networking networking the networking
-- @tparam string detectable_advn_nm who did the detectable thing
-- @tparam {string=true,...} the tags for what the detectable guy did
-- @treturn {string,...} the names of the adventurers that detected the adventurer
function detection.determine_and_network_detection(game_ctx, local_ctx, networking, detectable_advn_nm, tags)
  local detectors = detection.local_determine_detection(game_ctx, local_ctx, networking, detectable_advn_nm, tags)

  local events = {}
  for _, advn_nm in ipairs(detectors) do
    table.insert(events, AdventurerEvent:new{
      type = 'add_detect',
      adventurer_name = advn_nm,
      detected_name = detectable_advn_nm
    })
  end

  networking:broadcast_events(game_ctx, local_ctx, events)

  return detectors
end

return detection
