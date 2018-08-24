--- This is the event handling a /move command
-- @classmod MoveCommandEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')

local adventurers = require('functional/game_context/adventurers')
local system_messages = require('functional/system_messages')
local command_events = require('functional/command_events')

local LocalMoveEvent = require('classes/events/local/local_move')
local AdventurerEvent = require('classes/events/adventurer')
local AbilityEvent = require('classes/events/abilities/ability')

local MoveEvent = require('classes/events/move')
-- endregion

local MoveCommandEvent = {}

simple_serializer.inject(MoveCommandEvent)

function MoveCommandEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error('MoveCommandEvent is missing adventurer name (string)', 3)
  end

  if type(self.destination) ~= 'string' then
    error('MoveCommandEvent is missing destination (string)', 3)
  end
end

function MoveCommandEvent:process(game_ctx, local_ctx, networking)
  if local_ctx.id ~= 0 then return end

  local advn, advn_ind = adventurers.get_by_name(game_ctx, self.adventurer_name)
  if not advn then
    error('No adventurer with the name ' .. tostring(self.adventurer_name) .. ' found')
  end

  local evnt = LocalMoveEvent:new{ adventurer_ind = advn_ind, destination = self.destination, time_ms = 0 }

  local_ctx.listener_processor:invoke_pre_listeners(game_ctx, local_ctx, nil, evnt)
  evnt:process(game_ctx, local_ctx)
  local_ctx.listener_processor:invoke_post_listeners(game_ctx, local_ctx, nil, evnt)

  if not evnt.result then
    system_messages:send(game_ctx, local_ctx, networking, advn_ind, 'Cannot move to ' .. self.destination .. ': ' .. evnt.fail_reason)
    return
  end

  -- okay actually do the move then; note that the adventurer or destination may have changed
  local advn_name = game_ctx.adventurers[evnt.adventurer_ind].name
  self.adventurer_name = advn_name
  self.destination = evnt.destination
  local duration = evnt.time_ms
  local move_evnt = MoveEvent:new{ adventurer_name = self.adventurer_name, destination = self.destination }

  command_events.networked_set_ability(game_ctx, local_ctx, networking, self.adventurer_name, duration, move_evnt)
end

prototype.support(MoveCommandEvent, 'event')
prototype.support(MoveCommandEvent, 'serializable')
return class.create('MoveCommandEvent', MoveCommandEvent)
