--- Initializes the setup phase
-- @classmod InitSetupPhaseListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')
-- endregion


local InitSetupPhaseListener = {}

function InitSetupPhaseListener:get_events() return { NewGameEvent = true } end
function InitSetupPhaseListener:is_prelistener() return false end
function InitSetupPhaseListener:is_postlistener() return true end
function InitSetupPhaseListener:compare(other, pre) return 0 end
function InitSetupPhaseListener:process(game_ctx, local_ctx, networking, event)
  if local_ctx.id ~= 0 then error('should not get here') end

  game_ctx.in_setup_phase = true
end

prototype.support(InitSetupPhaseListener, 'listener')
return class.create('InitSetupPhaseListener', InitSetupPhaseListener)
