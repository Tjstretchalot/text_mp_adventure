--- Adventurers may or may not know about everyones location. This module
-- makes it easier to automatically handle potential "detection events", which
-- are situations where an adventurer does something that would alert other
-- adventurers.
--
-- @module detection

-- region imports
local adventurers = require('functional/game_context/adventurers')
local array = require('functional/array')
local system_messages = require('functional/system_messages')

local LocalDetectableEvent = require('classes/events/local/local_detectable')
local LocalDetectorEvent = require('classes/events/local/local_detector')
local AdventurerEvent = require('classes/events/adventurer')
-- endregion

local detection = {}

--- Adventurers in the given location who have detected the given adventurer
-- AND are not the given adventurer are sent the given message.
--
-- @tparam GameContext game_ctx game context
-- @tparam LocalContext local_ctx local context
-- @tparam Networking networking networking
-- @tparam string|{string,...} location names
-- @tparam string message the message to send
-- @tparam string advn_nm the adventurer who we arent sending to and must be detected
function detection.send_to_detected_by(game_ctx, local_ctx, networking, locs, message, advn_nm)
  if type(locs) == 'string' then locs = { locs } end

  for _, loc in ipairs(locs) do
    local advns = adventurers.get_by_location(game_ctx, loc)

    for _, advn in ipairs(advns) do
      local detected = advn:is_detected(advn_nm)

      if advn.name ~= advn_nm and detected then
        system_messages:send(game_ctx, local_ctx, networking, advn.name,
          message, 0)
      end
    end
  end
end

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

--- Runs a LocalDetectorEvent in order to determine who is detected by the
-- adventurer actively searching for other adventurers. Requires some tags
-- for the evnet that the adventurer is performing (Typically the class name
-- of the event that calls this).
--
-- Returns the detected table of the event.
--
-- @tparam GameContext game_ctx the game context
-- @tparam LocalContext local_ctx the local context
-- @tparam Networking networking the networking
-- @tparam string detector_advn_nm who did the search
-- @tparam {string=true,...} the tags for what the detectable guy did
-- @treturn {string,...} the names of the adventurers that were detected by the adventurer
function detection.local_determine_search(game_ctx, local_ctx, networking, detector_advn_nm, tags)
  local evnt = LocalDetectorEvent:new{
    adventurer_name = detector_advn_nm,
    tags = tags
  }

  local_ctx.listener_processor:invoke_pre_listeners(game_ctx, local_ctx, networking, evnt)
  evnt:process(game_ctx, local_ctx, networking)
  local_ctx.listener_processor:invoke_post_listeners(game_ctx, local_ctx, networking, evnt)

  return evnt.detected
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

--- Determine who was detected by the detector performing a search.
--
-- @tparam GameContext game_ctx the game context
-- @tparam LocalContext local_ctx the local context
-- @tparam Networking networking the networking
-- @tparam string detector_advn_nm who did the search
-- @tparam {string=true,...} the tags for what the search guy did
-- @treturn {string,...} the names of the adventurers that the adventurer detected
function detection.determine_and_network_search(game_ctx, local_ctx, networking, detector_advn_nm, tags)
  local detected = detection.local_determine_search(game_ctx, local_ctx, networking, detector_advn_nm, tags)

  local events = {}
  for _, advn_nm in ipairs(detected) do
    table.insert(events, AdventurerEvent:new{
      type = 'add_detect',
      adventurer_name = detector_advn_nm,
      detected_name = advn_nm
    })
  end

  networking:broadcast_events(game_ctx, local_ctx, events)

  return detected
end

return detection
