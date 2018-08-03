--- The "in_setup_phase" argument is a boolean true if we are still
-- setting up the game

local GameContext = require('classes/game_context')

GameContext:add_serialize_hook('in_setup_phase')
GameContext:add_deserialize_hook('in_setup_phase')
