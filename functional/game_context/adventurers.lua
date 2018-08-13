--- Useful functions for working with adventurers
-- @module adventurers

local Adventurer = require('classes/adventurer')

require('classes/game_context/serializers/adventurers')
require('classes/game_context/serializers/adventurers_by_id')

local adventurers = {}

--- Add a new adventurer with the given name
-- @tparam GameContext game_ctx the game context
-- @tparam string name the name of the adventurer to add
-- @treturn Adventurer,number the new adventurer and his id
function adventurers.add_adventurer(game_ctx, name)
  if not game_ctx.adventurers then
    game_ctx.adventurers = {}
    game_ctx.adventurers_by_id = {}
  end

  local advn = Adventurer:new{name = name}
  game_ctx.adventurers[#game_ctx.adventurers + 1] = advn
  return advn, #game_ctx.adventurers
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

--- Find the adventurer with the given name
-- @tparam GameContext game_ctx the game context
-- @tparam string name the name to search
-- @treturn nil|Adventurer,number the adventurer with that name and his id or nil
function adventurers.get_by_name(game_ctx, name)
  if not game_ctx.adventurers then return nil end

  for ind, advn in ipairs(game_ctx.adventurers) do
    if advn.name == name then return advn, ind end
  end

  return nil
end

--- Find the adventurers at the given location
-- @tparam GameContext game_ctx the game context
-- @tparam string location the name of the location
-- @treturn {Adventurer,...} adventurers at that location
function adventurers.get_by_location(game_ctx, location)
  if not game_ctx.adventurers then return {} end

  local result = {}
  for _, advn in ipairs(game_ctx.adventurers) do
    for _, loc in ipairs(advn.locations) do
      if loc == location then
        table.insert(result, advn)
        break
      end
    end
  end

  return result
end

--- Get the adventurer for the local player, if there is one
-- @tparam GameContext game_ctx the game context
-- @tparam LocalContext local_ctx the local context
-- @treturn nil|Adventurer the local adventurer
function adventurers.get_local_adventurer(game_ctx, local_ctx)
  return adventurers.get_adventurer(game_ctx, local_ctx.id)
end

--- Get the name of the adventurer of the local player, if there is one
-- @tparam GameContext game_ctx the game context
-- @tparam LocalContext local_ctx the local context
-- @treturn nil|string the name of the local adventurer
function adventurers.get_local_name(game_ctx, local_ctx)
  local local_advn = adventurers.get_local_adventurer(game_ctx, local_ctx)
  if not local_advn then return nil end
  return local_advn.name
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

  if game_ctx.adventurers[adventurer_ind].attached_id then
    adventurers.unset_adventurer(game_ctx, game_ctx.adventurers[adventurer_ind].attached_id)
  end

  game_ctx.adventurers[adventurer_ind].attached_id = id
  game_ctx.adventurers_by_id[id] = adventurer_ind
end

--- Set the specialization of the given adventurer
-- @tparam GameContext game_ctx the game context
-- @tparam number advn_id the index of the adventurer
-- @tparam string spec the name of the specialization
function adventurers.set_specialization(game_ctx, advn_id, spec)
  game_ctx.adventurers[advn_id].specialization = spec
end

return adventurers
