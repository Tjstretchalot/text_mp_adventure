--- Provides a function to auto complete an ability listener.

local function noop() end
local function noop_compare() return 0 end
local function noop_true() return true end

return function(listener)
  if not listener.compare_listener then
    listener.compare_listener = noop_compare
  end

  if not listener.can_start_ability then
    listener.can_start_ability = noop_true
  end

  if not listener.on_ability_start_determined then
    listener.on_ability_start_determined = noop
  end

  if not listener.pre_ability_started then
    listener.pre_ability_started = noop
  end

  if not listener.post_ability_started then
    listener.post_ability_started = noop
  end

  if not listener.ability_progress then
    listener.ability_progress = noop
  end

  if not listener.ability_cancelled then
    listener.ability_cancelled = noop
  end

  if not listener.can_finish_ability then
    listener.can_finish_ability = noop_true
  end

  if not listener.on_ability_finish_determined then
    listener.on_ability_finish_determined = noop
  end

  if not listener.pre_ability then
    listener.pre_ability = noop
  end

  if not listener.post_ability then
    listener.post_ability = noop
  end
end
