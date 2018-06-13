--- This file unattaches the adventurer from a player when he leaves
-- @classmod UnattachAdventurerOnExitListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local adventurers = require('functional/game_context/adventurers')

local TalkEvent = require('classes/events/talk')
-- endregion


local UnattachAdventurerOnExitListener = {}

function UnattachAdventurerOnExitListener:get_events() return { ExitEvent = true } end
function UnattachAdventurerOnExitListener:is_prelistener() return false end
function UnattachAdventurerOnExitListener:is_postlistener() return true end
function UnattachAdventurerOnExitListener:process(game_ctx, local_ctx, networking, event)
  if event.id == nil or event.id == 0 then return end -- Don't do this for the host

  adventurers.unset_adventurer(game_ctx, event.id)
end

prototype.support(UnattachAdventurerOnExitListener, 'listener')
return class.create('UnattachAdventurerOnExitListener', UnattachAdventurerOnExitListener)
