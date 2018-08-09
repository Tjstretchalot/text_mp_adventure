--- Assigns specializations to the players
-- @module specialization_assigner

local specialization_assigner = {}

--- Assigns every player the 'test' specialization
-- @tparam GameContext game_ctx the game context
-- @tparam number number_of_players the number of players
-- @treturn {string,...}, {table,...} player specializations, bot configurations
local function assign_test(game_ctx, number_of_players)
  local players = {}
  for i=1, number_of_players do
    table.insert(players, 'test')
  end

  return players, {}
end

--- Randomly produces a set of specializations for the given
-- number of players.
--
-- This produces two arrays, one which is just a list of strings that
-- correspond with specialization names, and the other is a list of
-- bot configurations. Bot configurations can be converted into actual
-- bots using the BotFactory.
--
-- @tparam GameContext game_ctx the game context (used for settings)
-- @tparam number number_of_players how many real players there are
-- @treturn {string,...}, {table,...} player specializations, bot configurations
function specialization_assigner:assign(game_ctx, number_of_players)
  return assign_test(game_ctx, number_of_players)
end

return specialization_assigner
