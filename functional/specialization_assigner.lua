--- Assigns specializations to the players
-- @module specialization_assigner

local table = table
local math = math

local shuffle = require('functional/shuffle')

local specialization_assigner = {}

--- Assigns every player the 'test' specialization.
-- @tparam GameContext game_ctx the game context
-- @tparam number number_of_players the number of players
-- @treturn {string,...}, {table,...} player specializations, params for new BotAddEvents
local function assign_test(game_ctx, number_of_players)
  local players = {}
  for i=1, number_of_players do
    table.insert(players, 'test')
  end

  local bots = {}
  for i=1, 16 - number_of_players do
    table.insert(bots, { specialization = 'npc', bot_class_name = 'NPCBot' })
  end

  return players, bots
end

--- Randomly produces a set of specializations for the given
-- number of players.
--
-- This produces two arrays, one which is just a list of strings that
-- correspond with specialization names, and the other is a list of
-- bot configurations. Bot configurations are passed to the BotAddEvent
-- as the constructor arguments. Both results are shuffled.
--
-- @tparam GameContext game_ctx the game context (used for settings)
-- @tparam number number_of_players how many real players there are
-- @treturn {string,...}, {table,...} player specializations, bot configurations
function specialization_assigner:assign(game_ctx, number_of_players)
  local players, bots = assign_test(game_ctx, number_of_players)

  shuffle(players)
  shuffle(bots)
  return players, bots
end

return specialization_assigner
