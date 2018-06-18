--- The "day" argument is a table, it has two things; { is_day: boolean, time_to_next_cycle_ms: number }

local GameContext = require('classes/game_context')

GameContext:add_serialize_hook('day')
GameContext:add_deserialize_hook('day')
