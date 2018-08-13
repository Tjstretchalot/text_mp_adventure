--- Processes a /look command
-- @classmod LookEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')

local adventurers = require('functional/game_context/adventurers')
local system_messages = require('functional/system_messages')

local LocalLookEvent = require('classes/events/local/local_look')
-- endregion

local LookEvent = {}

simple_serializer.inject(LookEvent)

function LookEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error('LookEvent requires adventurer name!', 3)
  end
end

function LookEvent:process(game_ctx, local_ctx, networking)
  if local_ctx.id ~= 0 then return end

  local advn, advn_ind = adventurers.get_by_name(game_ctx, self.adventurer_name)

  local evnt = LocalLookEvent:new{ adventurer_ind = advn_ind }

  local_ctx.listener_processor:invoke_pre_listeners(game_ctx, local_ctx, nil, evnt)
  evnt:process(game_ctx, local_ctx)
  local_ctx.listener_processor:invoke_post_listeners(game_ctx, local_ctx, nil, evnt)

  if not evnt.result then
    system_messages:send(game_ctx, local_ctx, networking, advn_ind, 'Cannot look: ' .. evnt.fail_reason)
    return
  end

  advn_ind = evnt.adventurer_ind
  for _, message in ipairs(evnt.message) do
    system_messages:send(game_ctx, local_ctx, networking, advn_ind, message.text, message.indent)
  end
end

prototype.support(LookEvent, 'event')
prototype.support(LookEvent, 'serializable')
return class.create('LookEvent', LookEvent)
