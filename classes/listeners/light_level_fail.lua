--- Add a chance of failure due to light level for abilities
-- @classmod LightLevelFailListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local system_messages = require('functional/system_messages')
-- endregion

-- darkest to brightest
local lightnessToDesignName = {
  'darkness',
  'dimly lit',
  'brightly lit'
}

local lightNamesToLightness = {
  inside_dark = 1,
  outside_night = 2,
  inside_electricity = 3,
  outside_day = 3
}

local lightnessToFailChance = {
  0.50,
  0,
  0
}

-- TODO detecting players fail chance

local LightLevelFailListener = {}

function LightLevelFailListener:get_events() return { LocalFailEvent = true } end
function LightLevelFailListener:is_prelistener() return true end
function LightLevelFailListener:is_postlistener() return true end
function LightLevelFailListener:compare(other, pre) return 0 end

LightLevelFailListener.pre_listeners_by_event = {
  LocalFailEvent = function(self, game_ctx, local_ctx, networking, event)
    local advn = game_ctx.adventurers[event.adventurer_ind]

    local highest_light_level = 1
    for _, loc_nm in ipairs(advn.locations) do
      local loc = game_ctx.locations[loc_nm]

      local lighting = loc.lighting
      if lighting == 'outside' then
        lighting = game_ctx.day.is_day and 'outside_day' or 'outside_night'
      end

      local light_level = lightNamesToLightness[lighting]
      if light_level > highest_light_level then
        highest_light_level = light_level
      end
    end

    local failChance = lightnessToFailChance[highest_light_level]
    if failChance > 0 then
      event:add_fail_chance('multiplicative', failChance, 'light level')
    end
  end
}

LightLevelFailListener.post_listeners_by_event = {
  LocalFailEvent = function(self, game_ctx, local_ctx, networking, event)
    if event:was_triggered('light level') then
      system_messages:send(game_ctx, local_ctx, networking, event.adventurer_ind,
        'The light level caused you to fail.')
    end
  end
}

function LightLevelFailListener:process(game_ctx, local_ctx, networking, event, pre)
  local func
  if pre then
    func = self.pre_listeners_by_event[event.class_name]
  else
    func = self.post_listeners_by_event[event.class_name]
  end

  if func then func(self, game_ctx, local_ctx, networking, event) end
end

prototype.support(LightLevelFailListener, 'listener')
return class.create('LightLevelFailListener', LightLevelFailListener)
