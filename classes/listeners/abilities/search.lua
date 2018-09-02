--- This is the main listener for /search
-- @classmod SearchListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

require('prototypes/ability_listener')

local ability_listener_noops = require('functional/ability_listener_noops')
local adventurers = require('functional/game_context/adventurers')
local detection = require('functional/detection')
local system_messages = require('functional/system_messages')
-- endregion

local SearchListener = {}

function SearchListener:get_listen_ability()
  return 'DetectorEvent'
end

function SearchListener:post_ability_started(game_ctx, local_ctx, networking, event)
  if not event.ability.ability.serialized.tags.SearchCommandEvent then return end

  local advn_nm = event.adventurer_name
  local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)
  system_messages:send(game_ctx, local_ctx, networking, advn_ind,
    'Search started.')
  
  detection.send_to_detected_by(game_ctx, local_ctx, networking, advn.locations,
    string.format('%s begins looking around.', advn_nm), advn_nm)
end

function SearchListener:ability_cancelled(game_ctx, local_ctx, networking, cancelled_event, event, pre)
  if not pre then
    if not event.tags.SearchCommandEvent then return end
    local advn_nm = cancelled_event.adventurer_name
    local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)
    system_messages:send(game_ctx, local_ctx, networking, advn_ind,
      string.format('Search cancelled.', event.destination), 0)

    detection.send_to_detected_by(game_ctx, local_ctx, networking, advn.locations,
      string.format('%s cut his search off early.', advn_nm), advn_nm)
  end
end

function SearchListener:post_ability(game_ctx, local_ctx, networking, event)
  if not event.tags.SearchCommandEvent then return end

  local advn_nm = event.detector_advn_nm
  local advn, advn_ind = adventurers.get_by_name(game_ctx, advn_nm)
  system_messages:send(game_ctx, local_ctx, networking, advn_ind,
    'Search completed.', 0)

  detection.send_to_detected_by(game_ctx, local_ctx, networking, advn.locations,
    string.format('%s finished looking around.', advn_nm), advn_nm)
end


ability_listener_noops(SearchListener)
prototype.support(SearchListener, 'ability_listener')
return class.create('SearchListener', SearchListener)
