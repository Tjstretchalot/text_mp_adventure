--- This is a generic listener that invokes the local_fail event
-- on listeners in the appropriate spots
--
-- The raised listeners have the identifiers:
--   'AbiliityFailListener:can_finish_ability'
--      source: { event = callback event }
-- @classmod AbilityFailListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')
require('prototypes/ability_listener')

local LocalFailEvent = require('classes/events/local/local_fail')

local adventurers = require('functional/game_context/adventurers')
local ability_listener_noops = require('functional/ability_listener_noops')
-- endregion

local AbilityFailListener = {}

function AbilityFailListener:get_listen_ability()
  return 'all'
end

function AbilityFailListener:can_finish_ability(game_ctx, local_ctx, networking, event, raw_event)
  local advn, advn_ind = adventurers.get_by_name(game_ctx, raw_event.adventurer_name)

  local local_evnt = LocalFailEvent:new{
    adventurer_ind = advn_ind,
    identifier = 'AbilityFailListener:can_finish_ability',
    source = { event = event }
  }

  local_ctx.listener_processor:invoke_pre_listeners(game_ctx, local_ctx, networking, local_evnt)
  local_evnt:process(game_ctx, local_ctx)
  local_ctx.listener_processor:invoke_post_listeners(game_ctx, local_ctx, networking, local_evnt)

  return local_evnt.result
end

ability_listener_noops(AbilityFailListener)
prototype.support(AbilityFailListener, 'ability_listener')
return class.create('AbilityFailListener', AbilityFailListener)
