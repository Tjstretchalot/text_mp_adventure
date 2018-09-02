--- Add a chance of failure due to light level for abilities
-- @classmod LightLevelFailListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local adventurers = require('functional/game_context/adventurers')
local lighting = require('functional/lighting')
local system_messages = require('functional/system_messages')
-- endregion

local lightness_to_fail_chance = {
  [lighting.DARKNESS] = 0.50,
  [lighting.DIMLY_LIT] = 0,
  [lighting.BRIGHTLY_LIT] = 0
}

local lightness_to_detect_fail_chance = {
  [lighting.DARKNESS] = 0.9,
  [lighting.DIMLY_LIT] = 0.5,
  [lighting.BRIGHTLY_LIT] = 0
}

local LightLevelFailListener = {}

function LightLevelFailListener:get_events() return { LocalFailEvent = true } end
function LightLevelFailListener:is_prelistener() return true end
function LightLevelFailListener:is_postlistener() return true end
function LightLevelFailListener:compare(other, pre) return 0 end

LightLevelFailListener.pre_listeners_by_identifier = {
  ['AbilityFailListener:can_finish_ability'] = function(self, game_ctx, local_ctx, networking, event)
    local advn = game_ctx.adventurers[event.adventurer_ind]
    local light_level = lighting.get_for_advn(game_ctx, advn)
    local fail_chance = lightness_to_fail_chance[light_level]

    if fail_chance > 0 then
      event:add_fail_chance('multiplicative', fail_chance, 'light level')
    end
  end,
  ['LocalDetectableEvent'] = function(self, game_ctx, local_ctx, networking, event)
    local advn_to_detect, advn_to_detect_ind = adventurers.get_by_name(game_ctx, event.source.adventurer_name)
    local light_level = lighting.get_for_advn(game_ctx, advn_to_detect)
    local fail_chance = lightness_to_detect_fail_chance[light_level]

    if fail_chance > 0 then
      event:add_fail_chance('multiplicative', fail_chance, 'light level')
    end
  end,
  ['LocalDetectorEvent'] = function(self, game_ctx, local_ctx, networking, event)
    local advn_to_detect, advn_to_detect_ind = adventurers.get_by_name(game_ctx, event.source.detectable_name)
    local light_level = lighting.get_for_advn(game_ctx, advn_to_detect)
    local fail_chance = lightness_to_detect_fail_chance[light_level]

    if fail_chance > 0 then
      event:add_fail_chance('multiplicative', fail_chance, 'light level')
    end
  end
}

LightLevelFailListener.post_listeners_by_identifier = {
  ['AbilityFailListener:can_finish_ability'] = function(self, game_ctx, local_ctx, networking, event)
    if event:was_triggered('light level') then
      system_messages:send(game_ctx, local_ctx, networking, event.adventurer_ind,
        'The light level caused you to fail.')
    end
  end
}

function LightLevelFailListener:process(game_ctx, local_ctx, networking, event, pre)
  local func
  if pre then
    func = self.pre_listeners_by_identifier[event.identifier]
  else
    func = self.post_listeners_by_identifier[event.identifier]
  end

  if func then func(self, game_ctx, local_ctx, networking, event) end
end

prototype.support(LightLevelFailListener, 'listener')
return class.create('LightLevelFailListener', LightLevelFailListener)
