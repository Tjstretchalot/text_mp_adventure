--- This serializes an adventurers table in the game context
-- The adventurers table is an array of adventurers

local GameContext = require('classes/game_context')

local Adventurer = require('classes/adventurer')

GameContext:add_serialize_hook('adventurers') -- use default
GameContext:add_deserialize_hook('adventurers', function(cls, serd, copy, _, serd_advnts)
  local advns = {}
  for k,v in ipairs(serd_advnts) do
    advns[k] = Adventurer:new(v)
  end
  copy.adventurers = advns
end)

GameContext:add_context_changed_hook('adventurers', function(self, game_ctx, k, v)
  for _, advn in ipairs(v) do
    advn:context_changed(game_ctx)
  end
end)
