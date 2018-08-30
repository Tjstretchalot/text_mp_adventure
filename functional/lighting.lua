--- Utility functions/constants for lighting
-- @module lighting

local lighting = {}

-- These are the three levels that affect gameplay
lighting.DARKNESS = 1
lighting.DIMLY_LIT = 2
lighting.BRIGHTLY_LIT = 3

-- These are aliases for common lighting types to their corresponding
-- light level (as a number)
lighting.SOURCES = {
  inside_dark = lighting.DARKNESS,
  inside_electricity = lighting.BRIGHTLY_LIT,
  outside_night = lighting.DIMLY_LIT,
  outside_day = lighting.BRIGHTLY_LIT
}

--- Converts from the numeric light level to a lowercase string
-- describing the light level
lighting.LIGHT_TO_NAME = {
  [lighting.DARKNESS] = 'darkness',
  [lighting.DIMLY_LIT] = 'dimly lit',
  [lighting.BRIGHTLY_LIT] = 'brightly lit'
}

--- Calculates the light level for the given adventurer
-- @tparam GameContext game_ctx the game context
-- @tparam Adventurer adven the adventurer
-- @treturn number either DARKNESS, DIMLY_LIT, or BRIGHTLY_LIT
function lighting.get_for_advn(game_ctx, adven)
  -- use best lighting
  local best = lighting.DARKNESS
  for _, loc_nm in ipairs(adven.locations) do
    local loc = game_ctx.locations[loc_nm]

    local light = loc.lighting
    if light == 'outside' then
      light = game_ctx.day.is_day and 'outside_day' or 'outside_night'
    end

    local light_num = lighting.SOURCES[light]
    if light_num > best then
      best = light_num
    end
  end

  return best
end

return lighting
