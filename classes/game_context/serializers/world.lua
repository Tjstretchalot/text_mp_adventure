--- Contains the entire world connection graph
local GameContext = require('classes/game_context')
local World = require('classes/world/world')

GameContext:add_serialize_hook('world', function(self, copy, k, v)
  copy[k] = v:serialize()
end)
GameContext:add_deserialize_hook('world', function(cls, serd, copy, k, v)
  copy[k] = World.deserialize(v)
end)
