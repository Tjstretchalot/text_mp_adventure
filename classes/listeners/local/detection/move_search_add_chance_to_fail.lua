--- Adds a 25% (multiplicative) chance to fail when searching areas via
-- the automatic scan from a move.
-- @classmod MoveSearchAddChanceToFailListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local adventurers = require('functional/game_context/adventurers')
-- endregion


local MoveSearchAddChanceToFailListener = {}

function MoveSearchAddChanceToFailListener:get_events() return { LocalFailEvent = true } end
function MoveSearchAddChanceToFailListener:is_prelistener() return true end
function MoveSearchAddChanceToFailListener:is_postlistener() return false end
function MoveSearchAddChanceToFailListener:compare(other, pre) return 0 end
function MoveSearchAddChanceToFailListener:process(game_ctx, local_ctx, networking, event)
  if event.identifier ~= 'LocalDetectorEvent' then return end
  if not event.source.event_tags.MoveListener then return end

  event:add_fail_chance('multiplicative', 0.25, 'MoveSearchAddChanceToFailListener') 
end

prototype.support(MoveSearchAddChanceToFailListener, 'listener')
return class.create('MoveSearchAddChanceToFailListener', MoveSearchAddChanceToFailListener)
