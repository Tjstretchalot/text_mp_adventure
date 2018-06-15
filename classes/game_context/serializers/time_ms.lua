--- The time_ms primitive, which is how long the game has been running
-- in milliseconds.
local GameContext = require('classes/game_context')

GameContext:add_serialize_hook('time_ms', function(self, copy, k, v)
  copy[k] = v
end)
GameContext:add_deserialize_hook('time_ms', function(cls, serd, copy, k, serd_time)
  copy[k] = serd_time
end)
