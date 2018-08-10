--- Convienence functions for interacting with locations
-- @module locations

local locations = {}

--- Add a new location to the game context
-- @tparam GameContext game_ctx the game context
-- @tparam Location loc the location to add
-- @treturn Location loc
function locations.add_location(game_ctx, loc)
  if not game_ctx.locations then game_ctx.locations = {} end

  if game_ctx.locations[loc.name] then
    error('Already have a location with the name ' .. loc.name)
  end

  game_ctx.locations[loc.name] = loc
  return loc
end

--- Delete the location from the game context
-- @tparam GameContext game_ctx the game context
-- @tparam string loc the name of the location to delete
-- @treturn boolean success
function locations.delete_location(game_ctx, loc)
  if not game_ctx.locations then return false end
  if not game_ctx.locations[loc] then return false end

  game_ctx.locations[loc] = nil
  return true
end

return locations
