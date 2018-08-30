--- Utility module for using and converting from/to game time
-- This module assumes millisecond granularity.
--
-- In the game, "day" lasts 90 real-seconds and "night" lasts 30 real-seconds,
-- however "day" spans a 12 hour period (8am-8pm) and "night" spans
-- a 12 hour period (8pm-8am). Thus, time literally moves 3 times
-- faster at night (in real time).
--
-- @module game_time

local game_time = {}

local MILLISECONDS_PER_SECOND = 1000
local SECONDS_PER_MINUTE = 60
local MINUTES_PER_HOUR = 60
local HOURS_PER_DAY = 24

local MILLISECONDS_PER_HOUR = MILLISECONDS_PER_SECOND * SECONDS_PER_MINUTE * MINUTES_PER_HOUR
local MILLISECONDS_PER_DAY = MILLISECONDS_PER_HOUR * HOURS_PER_DAY

--- The time that day starts in the game on a 24-hour clock
game_time.GAME_24_HOUR_START_OF_DAY = 8

--- The time that night starts in the game on a 24-hour clock
game_time.GAME_24_HOUR_END_OF_DAY = 20

--- How many seconds in real time does day last?
game_time.REAL_SECONDS_PER_GAME_DAY = 90

--- How many seconds in real time does night last?
game_time.REAL_SECONDS_PER_GAME_NIGHT = 30

-- THE REMAINDER IS CALCULATED FROM THE ABOVE 4 CONSTANTS

--- How many game-hours are in the day-cycle of a game-day
game_time.GAME_HOURS_DAY = game_time.GAME_24_HOUR_END_OF_DAY - game_time.GAME_24_HOUR_START_OF_DAY

--- How many game-hours are in the night-cycle of a game-day
game_time.GAME_HOURS_NIGHT = HOURS_PER_DAY - game_time.GAME_HOURS_DAY

-- How many game-milliseconds are there in day-part of a day
game_time.GAME_MILLISECONDS_DAY = MILLISECONDS_PER_HOUR * game_time.GAME_HOURS_DAY

--- How many game-milliseconds are there in the night-part of a day
game_time.GAME_MILLISECONDS_NIGHT = MILLISECONDS_PER_HOUR * game_time.GAME_HOURS_NIGHT

--- How many real-time milliseconds occur during the game-day
game_time.REAL_MILLISECONDS_PER_GAME_DAY = MILLISECONDS_PER_SECOND * game_time.REAL_SECONDS_PER_GAME_DAY

--- How many real-time milliseconds occur during the game-night
game_time.REAL_MILLISECONDS_PER_GAME_NIGHT = MILLISECONDS_PER_SECOND * game_time.REAL_SECONDS_PER_GAME_NIGHT

--- What should we multiply REAL TIME by to get GAME TIME when its the DAY PART of a day?
game_time.GAME_TIME_MULTIPLIER_DURING_DAY = game_time.GAME_MILLISECONDS_DAY / game_time.REAL_MILLISECONDS_PER_GAME_DAY

--- What should we multiply REAL TIME by to get GAME TIME when its the NIGHT PART of a day?
game_time.GAME_TIME_MULTIPLIER_DURING_NIGHT = game_time.GAME_MILLISECONDS_NIGHT / game_time.REAL_MILLISECONDS_PER_GAME_NIGHT

--- Milliseconds since midnight for the start of daytime
game_time.GAME_MILLISECONDS_FOR_START_OF_DAY = game_time.GAME_24_HOUR_START_OF_DAY * MILLISECONDS_PER_HOUR

--- Milliseconds since midnight for end of daytime
game_time.GAME_MILLISECONDS_FOR_END_OF_DAY = game_time.GAME_24_HOUR_END_OF_DAY * MILLISECONDS_PER_HOUR

--- Converts the specified number of real milliseconds to game time
-- based on if it is day or not
-- @tparam number real_ms the number of real milliseconds that have passed
-- @tparam boolean day if it is day
-- @treturn number number of game milliseconds that have passed
function game_time.convert_to_game(real_ms, day)
  if day then
    return real_ms * game_time.GAME_TIME_MULTIPLIER_DURING_DAY
  else
    return real_ms * game_time.GAME_TIME_MULTIPLIER_DURING_NIGHT
  end
end

--- Converts the specified number of game milliseconds to real time
-- based on if its day or not
-- @tparam number game_ms the number of game milliseconds
-- @tparam boolean day if it is day
-- @treturn number number of real milliseconds that pass during game_ms
function game_time.convert_to_real(game_ms, day)
  if day then
    return game_ms / game_time.GAME_TIME_MULTIPLIER_DURING_DAY
  else
    return game_ms / game_time.GAME_TIME_MULTIPLIER_DURING_NIGHT
  end
end

--- Convert the number of milliseconds since midnight to a pretty
-- 24 hour clock representation (ie 01:00 for 1am)
-- @tparam number ms_since_midnight milliseconds since midnight
-- @treturn string 24-hour clock representation
function game_time.pretty_24_hour_clock(ms_since_midnight)
  local hours_since_midnight = math.floor(ms_since_midnight / MILLISECONDS_PER_HOUR)
  local ms_since_latest_hour = ms_since_midnight - (hours_since_midnight * MILLISECONDS_PER_HOUR)

  local minutes_since_latest_hour = math.floor(ms_since_latest_hour / (MILLISECONDS_PER_SECOND * SECONDS_PER_MINUTE))

  return string.format('%.2d:%.2d', hours_since_midnight, minutes_since_latest_hour)
end

--- Convert the number of milliseconds since midnight to a pretty
-- 12 hour clock representation (ie 1:00am)
-- @tparam number ms_since_midnight milliseconds since midnight
-- @treturn string 12-hour clock representation
function game_time.pretty_12_hour_clock(ms_since_midnight)
  local hours_since_midnight = math.floor(ms_since_midnight / MILLISECONDS_PER_HOUR)
  local ms_since_latest_hour = ms_since_midnight - (hours_since_midnight * MILLISECONDS_PER_HOUR)

  local minutes_since_latest_hour = math.floor(ms_since_latest_hour / (MILLISECONDS_PER_SECOND * SECONDS_PER_MINUTE))

  local hours = hours_since_midnight
  local mins = minutes_since_latest_hour
  local am = true

  if hours >= 12 then
    am = false
    if hours >= 13 then
      hours = hours - 12
    end
  elseif hours == 0 then
    hours = 12
  end

  return string.format('%d:%.2d%s', hours, mins, am and 'am' or 'pm')
end

--- Determines if the number of milliseconds since midnight corresponds
-- with the day part of the day
-- @tparam number ms_since_midnight the milliseconds since midnight
-- @treturn boolean true if ms_since_midnight represents daytime, false if nighttime
function game_time.is_day(ms_since_midnight)
  if ms_since_midnight < game_time.GAME_MILLISECONDS_FOR_START_OF_DAY then return false end
  if ms_since_midnight >= game_time.GAME_MILLISECONDS_FOR_END_OF_DAY then return false end

  return true
end

--- Calculates number of milliseconds until night
-- Assumes that ms_since_midnight is a daytime value.
-- @tparam number ms_since_midnight number of milliseconds since midnight
-- @treturn number number of milliseconds until night
function game_time.game_ms_until_night(ms_since_midnight)
  return game_time.GAME_MILLISECONDS_FOR_END_OF_DAY - ms_since_midnight
end

--- Calculates number of milliseconds until day
-- Assumes that ms_since_midnight is a nighttime value
-- @tparam number ms_since_midnight number of milliseconds since midnight
-- @treturn number of milliseconds until day
function game_time.game_ms_until_day(ms_since_midnight)
  if ms_since_midnight >= game_time.GAME_MILLISECONDS_FOR_END_OF_DAY then
    local ms_until_midnight = MILLISECONDS_PER_DAY - ms_since_midnight
    return ms_until_midnight + game_time.GAME_MILLISECONDS_FOR_START_OF_DAY
  end

  -- must be before start of day
  return game_time.GAME_MILLISECONDS_FOR_START_OF_DAY - ms_since_midnight
end

--- Calculates and returns the new game time given the elapsing of real time.
-- Assumes that the game time elapsed after conversion is fairly small (meaning
-- we won't pass midnight and start the day in one call, for example)
-- @tparam number game_ms_since_midnight the milliseconds since midnight, game time
-- @tparam number real_ms_elapsed the real milliseconds elapsed
-- @treturn number the new game milliseconds since midnight
-- @treturn boolean true if the day cycled (ie we went from before midnight to after midnight)
-- @treturn boolean true if we went from day to night or night to day
-- @treturn boolean true if it is now day, false if it is now night
-- @treturn number milliseconds of game time that passed during the day
-- @treturn number milliseconds of game time that passed during the night
function game_time.add_real_time_to_game_ms_since_midnight(game_ms_since_midnight, real_ms_elapsed)
  local day = game_time.is_day(game_ms_since_midnight)

  if day then
    local game_ms_until_night = game_time.game_ms_until_night(game_ms_since_midnight)
    local game_ms_elapsed_if_all_day = game_time.convert_to_game(real_ms_elapsed, true)

    if game_ms_elapsed_if_all_day < game_ms_until_night then
      local new_game_ms = game_ms_since_midnight + game_ms_elapsed_if_all_day
      return new_game_ms, false, false, true, game_ms_elapsed_if_all_day, 0
    end

    local game_ms_elapsed_during_day = game_ms_until_night
    local real_ms_elapsed_during_day = game_time.convert_to_real(game_ms_elapsed_during_day, true)
    local real_ms_elapsed_during_night = real_ms_elapsed - real_ms_elapsed_during_day
    local game_ms_elapsed_during_night = game_time.convert_to_game(real_ms_elapsed_during_night, false)
    local new_game_ms = game_ms_since_midnight + game_ms_elapsed_during_day + game_ms_elapsed_during_night

    return new_game_ms, false, true, false, game_ms_elapsed_during_day, game_ms_elapsed_during_night
  elseif game_ms_since_midnight >= game_time.GAME_MILLISECONDS_FOR_END_OF_DAY then
    local game_ms_until_midnight = MILLISECONDS_PER_DAY - game_ms_since_midnight
    local game_ms_elapsed_night = game_time.convert_to_game(real_ms_elapsed, false)

    if game_ms_elapsed_night < game_ms_until_midnight then
      local new_game_ms = game_ms_since_midnight + game_ms_elapsed_night
      return new_game_ms, false, false, false, 0, game_ms_elapsed_night
    end

    local new_game_ms = game_ms_elapsed_night - game_ms_until_midnight
    return new_game_ms, true, false, false, 0, game_ms_elapsed_night
  else
    local game_ms_until_day = game_time.game_ms_until_day(game_ms_since_midnight, false)
    local game_ms_elapsed_if_all_night = game_time.convert_to_game(real_ms_elapsed, false)

    if game_ms_elapsed_if_all_night < game_ms_until_day then
      local new_game_ms = game_ms_since_midnight + game_ms_elapsed_if_all_night
      return new_game_ms, false, false, false, 0, game_ms_elapsed_if_all_night
    end

    local game_ms_elapsed_during_night = game_ms_until_day
    local real_ms_elapsed_during_night = game_time.convert_to_real(game_ms_elapsed_during_night, false)
    local real_ms_elapsed_during_day = real_ms_elapsed - real_ms_elapsed_during_night
    local game_ms_elapsed_during_day = game_time.convert_to_game(real_ms_elapsed_during_day, true)
    local new_game_ms = game_ms_since_midnight + game_ms_elapsed_during_night + game_ms_elapsed_during_day

    return new_game_ms, false, true, true, game_ms_elapsed_during_day, game_ms_elapsed_during_night
  end
end

return game_time
