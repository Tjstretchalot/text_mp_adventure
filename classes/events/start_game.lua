--- This event is invoked when the host has started the round.
-- @classmod StartGameEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
local word_wrap = require('functional/word_wrap')
local spec_assigner = require('functional/specialization_assigner')
local spec_pool = require('classes/specializations/specialization_pool')

local AdventurerEvent = require('classes/events/adventurer')
local LocationEvent = require('classes/events/location')
local LoadWorldEvent = require('classes/events/load_world')

local World = require('classes/world/world')
-- endregion

local StartGameEvent = {}

simple_serializer.inject(StartGameEvent)

function StartGameEvent:init()
end

function StartGameEvent:process(game_ctx, local_ctx, networking)
  print('\27[2K\r=====\27[4mGame Started\27[0m=====')

  word_wrap.reload_console_width()
  game_ctx.in_setup_phase = false
  if local_ctx.id ~= 0 then return end

  -- region load world and locs
  local file = io.open('data/world.json')
  local serd_world = json.decode(file:read('*all'))
  file:close()

  file = io.open('data/locations.json')
  local serd_locs = json.decode(file:read('*all'))
  file:close()
  -- endregion

  -- region decide adventurer stuff
  local num_players = #game_ctx.adventurers
  local specs, _ = spec_assigner:assign(game_ctx, num_players)
  local advn_locs = {}
  for k, advn in ipairs(game_ctx.adventurers) do
    local spec = spec_pool:get_by_name(specs[k])
    table.insert(advn_locs, spec:get_random_starting_location(game_ctx, local_ctx))
  end
  -- endregion

  -- region push world
  networking:broadcast_events(game_ctx, local_ctx, { LoadWorldEvent:new{ world = serd_world } })
  -- endregion

  -- region push replace locations
  local evnts = {}
  for k, loc in pairs(game_ctx.locations) do
    table.insert(evnts, LocationEvent:new{ type = 'delete', location = k })
  end
  networking:broadcast_events(game_ctx, local_ctx, evnts)
  evnts = {}
  for _, serd_loc in ipairs(serd_locs) do
    table.insert(evnts, LocationEvent:new{ type = 'new', location = serd_loc })
  end
  networking:broadcast_events(game_ctx, local_ctx, evnts)
  -- endregion

  -- region update adventurers
  evnts = {}
  for k, advn in ipairs(game_ctx.adventurers) do
    table.insert(evnts, AdventurerEvent:new{ type = 'spec', adventurer_name = advn.name, specialization = specs[k] })
    table.insert(evnts, AdventurerEvent:new{ type = 'move', adventurer_name = advn.name, location_name = advn_locs[k] })
  end
  networking:broadcast_events(game_ctx, local_ctx, evnts)
  -- endregion
end

prototype.support(StartGameEvent, 'event')
prototype.support(StartGameEvent, 'serializable')
return class.create('StartGameEvent', StartGameEvent)
