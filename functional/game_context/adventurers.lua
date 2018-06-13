--- Useful functions for working with adventurers
-- @module adventurers

local Adventurer = require('classes/adventurer')

require('classes/game_context/serializers/adventurers')
require('classes/game_context/serializers/adventurers_by_id')

local adventurers = {}

--- Add a new adventurer with the given name
-- @tparam GameContext game_ctx the game context
-- @tparam string name the name of the adventurer to add
function adventurers.add_adventurer(game_ctx, name)
  if not game_ctx.adventurers then
    game_ctx.adventurers = {}
    game_ctx.adventurers_by_id = {}
  end

  game_ctx.adventurers[#game_ctx.adventurers + 1] = Adventurer:new{name = name}
end

--- Get the adventurer for the given player, if there is one
-- @tparam GameContext game_ctx the game context
-- @tparam number id the id of the player
-- @treturn nil|Adventurer the adventurer for that player, or nil
function adventurers.get_adventurer(game_ctx, id)
  if game_ctx.adventurers and game_ctx.adventurers_by_id then
    if game_ctx.adventurers_by_id[id] then
      return game_ctx.adventurers[game_ctx.adventurers_by_id[id]]
    end
  end
  return nil
end

--- Get the adventurer for the local player, if there is one
-- @tparam GameContext game_ctx the game context
-- @tparam LocalContext local_ctx the local context
-- @treturn nil|Adventurer the local adventurer
function adventurers.get_local_adventurer(game_ctx, local_ctx)
  return adventurers.get_adventurer(game_ctx, local_ctx.id)
end

--- Unattach the given adventurer to the given player id
-- @tparam GameContext game_ctx the game context
-- @tparam number id the id of the player to unset adventurer on
function adventurers.unset_adventurer(game_ctx, id)
  if game_ctx.adventurers and game_ctx.adventurers_by_id then
    game_ctx.adventurers[game_ctx.adventurers_by_id[id]].attached_id = nil
    game_ctx.adventurers_by_id[id] = nil
  end
end

--- Attach the adventurer index to the given player
-- @tparam GameContext game_ctx the game context
-- @tparam number id the player id
-- @tparam number adventurer_ind the index in adventurers to attach
function adventurers.set_adventurer(game_ctx, id, adventurer_ind)
  if game_ctx.adventurers_by_id[id] then
    adventurers.unset_adventurer(game_ctx, id)
  end

  game_ctx.adventurers[adventurer_ind].attached_id = id
  game_ctx.adventurers_by_id[id] = adventurer_ind
end

return adventurers
