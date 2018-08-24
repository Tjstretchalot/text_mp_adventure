--- Utility functions for events that handle commands
-- @module command_events

local adventurers = require('functional/game_context/adventurers')

local AbilityEvent = require('classes/events/abilities/ability')
local AbilityCancelledEvent = require('classes/events/abilities/ability_cancelled')

local command_events = {}

--- This function broadcasts the events required to set
-- the ability for the given adventurer to the given callback
-- event.
--
-- @tparam GameContext game_ctx the state of the game
-- @tparam LocalContext local_ctx the local context
-- @tparam Networking networking networking
-- @tparam string adventurer_name the name of the adventurer whose ability we should set
-- @tparam number duration how long the ability requires in game-milliseconds
-- @tparam Event callback_event the event specific to the ability
function command_events.networked_set_ability(game_ctx, local_ctx, networking, adventurer_name, duration, callback_event)
  local advn = adventurers.get_by_name(game_ctx, adventurer_name)

  local events = {}
  if advn.active_ability then
    table.insert(events, AbilityCancelledEvent:new{adventurer_name = adventurer_name})
  end

  table.insert(events, AbilityEvent:new{ adventurer_name = adventurer_name, duration = duration, callback_event = callback_event })
  networking:broadcast_events(game_ctx, local_ctx, events)
end

return command_events
