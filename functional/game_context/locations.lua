--- Convienence functions for interacting with locations
-- @module locations

local locations = {}

--- Add a new location to the game context
-- @tparam GameContext game_ctx the game context
-- @tparam Location loc the location to add
function locations.add_location(game_ctx, loc)
  if not game_ctx.locations then game_ctx.locations = {} end

  if game_ctx.locations[loc.name] then
    error('Already have a location with the name ' .. loc.name)
  end

  game_ctx.locations[loc.name] = loc
end

return locations
