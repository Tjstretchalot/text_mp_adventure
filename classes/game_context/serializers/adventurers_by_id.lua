--- This maps ids of players to ids of the adventurers they belong to
-- For example, game_ctx.adventurers_by_id[2] = 3 means that player by
-- index 2 is controlling the adventurer in adventurers at index 3

local GameContext = require('classes/game_context')

GameContext:add_serialize_hook('adventurers_by_id')
GameContext:add_deserialize_hook('adventurers_by_id', 'numeric_keys')
