--- Greets new connections
-- @classmod GreetListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local TalkEvent = require('classes/events/talk')
-- endregion


local GreetListener = {}

function GreetListener:get_events() return { ClientConnectEvent = true } end
function GreetListener:is_prelistener() return false end
function GreetListener:is_postlistener() return true end
function GreetListener:compare(other, pre) return 0 end
function GreetListener:process(game_ctx, local_ctx, networking, event)
  if local_ctx.id ~= 0 then return end

  networking:broadcast_events(game_ctx, local_ctx, { TalkEvent:new{message = 'A new client with id ' .. event.id .. ' just joined!', id = -1} })
end

prototype.support(GreetListener, 'listener')
return class.create('GreetListener', GreetListener)
