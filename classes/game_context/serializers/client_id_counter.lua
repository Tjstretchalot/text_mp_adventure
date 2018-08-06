--- This counter is used for assigning ids to new connections

local GameContext = require('classes/game_context')

GameContext:add_serialize_hook('client_id_counter')
GameContext:add_deserialize_hook('client_id_counter')
