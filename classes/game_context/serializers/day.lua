--- The "day" argument is a table: { is_day: boolean, game_ms_since_midnight: number }

local GameContext = require('classes/game_context')

GameContext:add_serialize_hook('day')
GameContext:add_deserialize_hook('day')
