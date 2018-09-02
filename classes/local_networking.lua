--- This class does not actually network anything, it just handles the event
-- queue. Since it's simpler to understand this one, it can be easier to verify
-- events are being run in the correct order.
-- @classmod LocalNetworking

-- region imports
local prototype = require('prototypes/prototype')
local class = require('classes/class')

require('prototypes/networking')

local deque = require('classes/dequeue/deque')
local event_queue = require('classes/event_queue')
-- endregion

local LocalNetworking = {}

function LocalNetworking:init()
  self.local_queue = deque.new()
  self.event_queue = event_queue:new()
end

function LocalNetworking:process_local_queue(game_ctx, local_ctx)
  local event = self.local_queue:pop_left()

  while event do
    self.event_queue:enqueue(event)
    -- here is where we should send the event to clients
    event = self.local_queue:pop_left()
  end
end

function LocalNetworking:update(game_ctx, local_ctx)
  while true do
    -- if local queue not empty -> process local queue
    self:process_local_queue(game_ctx, local_ctx)
    local event = self.event_queue:dequeue()
    if not event then
      if #self.event_queue.stack == 0 then
        -- event queue empty -> finish
        break
      end
      -- event queue top of stack empty -> pop

      -- here we should network signal EVENT_FINISHED
      self.event_queue:pop()
    else
      -- event queue not empty -> process next event
      -- here we should network signal EVENT_STARTED
      self.event_queue:push()
      local_ctx.listener_processor:invoke_pre_listeners(game_ctx, local_ctx, self, event)
      event:process(game_ctx, local_ctx, self)
      local_ctx.listener_processor:invoke_post_listeners(game_ctx, local_ctx, self, event)
    end
  end
end

function LocalNetworking:broadcast_events(game_ctx, local_ctx, events)
  for _, evnt in ipairs(events) do
    self.local_queue:push_right(evnt)
  end
end

function LocalNetworking:disconnect(game_ctx, local_ctx)
end

prototype.support(LocalNetworking, 'networking')
return class.create('LocalNetworking', LocalNetworking)
