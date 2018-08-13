--- This is the event handling a /move command
-- @classmod MoveEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')

local adventurers = require('functional/game_context/adventurers')
local system_messages = require('functional/system_messages')

local LocalMoveEvent = require('classes/events/local/local_move')
local AdventurerEvent = require('classes/events/adventurer')
-- endregion

local MoveEvent = {}

simple_serializer.inject(MoveEvent)

function MoveEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error('MoveEvent is missing adventurer name (string)', 3)
  end

  if type(self.destination) ~= 'string' then
    error('MoveEvent is missing destination (string)', 3)
  end
end

function MoveEvent:process(game_ctx, local_ctx, networking)
  if local_ctx.id ~= 0 then return end

  local advn, advn_ind = adventurers.get_by_name(game_ctx, self.adventurer_name)
  if not advn then
    error('No adventurer with the name ' .. tostring(self.adventurer_name) .. ' found')
  end

  local evnt = LocalMoveEvent:new{ adventurer_ind = advn_ind, destination = self.destination }

  local_ctx.listener_processor:invoke_pre_listeners(game_ctx, local_ctx, nil, evnt)
  evnt:process(game_ctx, local_ctx)
  local_ctx.listener_processor:invoke_post_listeners(game_ctx, local_ctx, nil, evnt)

  if not evnt.result then
    system_messages:send(game_ctx, local_ctx, networking, advn_ind, 'Cannot move to ' .. self.destination .. ': ' .. evnt.fail_reason)
    return
  end

  -- okay actually do the move then; note that the adventurer or destination may have changed
  local advn_name = game_ctx.adventurers[evnt.adventurer_ind].name
  local dest = evnt.destination

  -- todo wrap the adventurer event in an ability or something
  system_messages:send(game_ctx, local_ctx, networking, advn_ind, 'Movement successful!')
  local advn_evnt = AdventurerEvent:new{ type = 'move', adventurer_name = advn_name, location_name = dest }
  networking:broadcast_events(game_ctx, local_ctx, { advn_evnt })
end

prototype.support(MoveEvent, 'event')
prototype.support(MoveEvent, 'serializable')
return class.create('MoveEvent', MoveEvent)
