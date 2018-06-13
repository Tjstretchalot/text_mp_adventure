--- Describes a FIFO queue for events
-- @classmod EventQueue

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

local events = require('classes/events/all')

local deque = require('classes/dequeue/deque')

local file = require('functional/file')
local array = require('functional/array')
-- endregion

local EventQueue = {}

-- region serializing
function EventQueue:serialize()
  local result = {}

  local _next = self.queue:iter_right()
  local event = _next()
  while event do
    result[#result + 1] = { event.class_name, event:serialize() }
    event = _next()
  end

  return result
end

function EventQueue.deserialize(serd)
  local queue = deque.new()

  for i, event in ipairs(serd) do
    queue:push_right(events[event[1]].deserialize(event[2]))
  end

  return EventQueue._wrapped_class:new{queue = queue}
end

function EventQueue:context_changed(game_ctx)
  local _next = self.queue:iter_right()
  local event = _next()
  while event do
    if event.context_changed then
      event:context_changed(game_ctx)
    end
  end
end
-- endregion

function EventQueue:init()
  if self.queue == nil then
    self.queue = deque.new()
  end
end

--- Enqueue the given event
-- @tparam Event event the event to enqueue
function EventQueue:enqueue(event)
  self.queue:push_right(event)
end

--- Dequeue the oldest event in the queue
-- @treturn bool|Event false if nothing left, otherwise the event
function EventQueue:dequeue()
  return self.queue:pop_left()
end

prototype.support(EventQueue, 'serializable')
return class.create('EventQueue', EventQueue)
