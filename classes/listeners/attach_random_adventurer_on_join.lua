--- Attaches a random adventurer with a random name when a player connects.
-- @classmod AttachRandomAdventurerOnJoinListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local adventurers = require('functional/game_context/adventurers')
local random_names = require('functional/random_names')

local AdventurerEvent = require('classes/events/adventurer')

-- endregion

local AttachRandomAdventurerOnJoinListener = {}

function AttachRandomAdventurerOnJoinListener:get_events() return { NewGameEvent = true, ClientConnectEvent = true } end
function AttachRandomAdventurerOnJoinListener:is_prelistener() return false end
function AttachRandomAdventurerOnJoinListener:is_postlistener() return true end
function AttachRandomAdventurerOnJoinListener:compare(other, pre)
  if other == 'SetupSpawnListener' then return 1 end

  return 0
end

function AttachRandomAdventurerOnJoinListener:process(game_ctx, local_ctx, networking, event)
  if local_ctx.id ~= 0 then return end

  local name = random_names:generate()
  while true do
    local found, _ = adventurers.get_by_name(name)

    if not found then break end
    name = random_names:generate()
  end

  local target_id
  if event.class_name == 'NewGameEvent' then
    target_id = 0
  else
    target_id = event.id
  end

  local add_evn = AdventurerEvent:new({ type = 'add', name = name })
  local set_evn = AdventurerEvent:new({ type = 'set', player_id = target_id, adventurer_name = name })
  local move_evn = AdventurerEvent:new({ type = 'move', adventurer_name = name, location_name = 'pregame' })

  networking:broadcast_events(game_ctx, local_ctx, { add_evn, set_evn, move_evn })
end

prototype.support(AttachRandomAdventurerOnJoinListener, 'listener')
return class.create('AttachRandomAdventurerOnJoinListener', AttachRandomAdventurerOnJoinListener)
