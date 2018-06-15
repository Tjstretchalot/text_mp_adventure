--- Serializes the locations table
-- The locations table maps location names to locations

local GameContext = require('classes/game_context')

local Location = require('classes/location')

GameContext:add_serialize_hook('locations', function(self, copy, k, v)
  local serd = {}

  for key, loc in pairs(v) do
    serd[key] = loc:serialize()
  end

  copy[k] = serd
end)

GameContext:add_deserialize_hook('locations', function(cls, serd, copy, _, serd_locs)
  local locs = {}
  for k,v in pairs(serd_locs) do
    locs[k] = Location.deserialize(v)
  end
  copy.locations = locs
end)

GameContext:add_context_changed_hook('locations', function(self, game_ctx, k, v)
  for _, loc in pairs(v) do
    loc:context_changed(game_ctx)
  end
end)
