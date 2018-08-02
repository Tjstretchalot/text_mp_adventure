--- Says farewell when a player leaves
-- @classmod SayFarewellListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')
local adventurers = require('functional/game_context/adventurers')

require('prototypes/listener')

local TalkEvent = require('classes/events/talk')
-- endregion


local SayFarewellListener = {}

function SayFarewellListener:get_events() return { ExitEvent = true } end
function SayFarewellListener:is_prelistener() return false end
function SayFarewellListener:is_postlistener() return true end
function SayFarewellListener:compare(other, pre) return 0 end
function SayFarewellListener:process(game_ctx, local_ctx, networking, event)
  if local_ctx.id ~= 0 then return end
  if event.id == nil or event.id == 0 then return end -- can't say farewell to host

  local name
  local advn = adventurers.get_adventurer(game_ctx, event.id)
  if advn then
    name = advn.name
  else
    name = 'client ' .. tostring(event.id)
  end

  networking:broadcast_events(game_ctx, local_ctx, {
    TalkEvent:new{message = 'Farewell ' .. name .. '!', id = -1}
  })
end

prototype.support(SayFarewellListener, 'listener')
return class.create('SayFarewellListener', SayFarewellListener)
