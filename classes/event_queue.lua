--- Describes a FIFO queue of events, but events pushed by an event/listeners
-- happen prior to other events. This is implemented via a LIFO stack of
-- queues
-- @classmod EventQueue

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

local events = require('classes/events/all')

local deque = require('classes/dequeue/deque')

local file = require('functional/file')
local array = require('functional/array')
local event_serializer = require('functional/event_serializer')
-- endregion

local EventQueue = {}

-- region serializing
--- Serializes a dequeue of events
-- @tparam deque que the queue to deserialize
-- @treturn table of primitives
local function ser_deque(que)
  local result = {}

  local _next = self.queue:iter_left()
  local event = _next()
  while event do
    table.insert(event, event_serializer.serialize())
    event = _next()
  end

  return result
end

--- Deserializes the dequeue of events from ser_deque
-- @tparam table serd the result from ser_deque
-- @treturn deque the original deque
local function deser_deque(serd)
  local result = deque.new()

  for _, event_serd in ipairs(serd) do
    result:push_right(event_serializer.deserialize(event_serd))
  end

  return result
end

--- Inform the deque of events that the context changed
-- @tparam GameContext game_ctx game context
-- @tparam deque que the queue of events to inform
local function context_changed_deque(game_ctx, que)
  local _next = que:iter_left()
  local event = _next()
  while event do
    event:context_changed(game_ctx)
    event = _next()
  end
end

function EventQueue:serialize()
  local serd_queue = ser_deque(self.queue)
  local serd_stack = {}
  for _, q in ipairs(self.stack) do
    table.insert(serd_stack, ser_deque(q))
  end

  return {
    queue = serd_dequeue,
    stack = serd_stack
  }
end

function EventQueue.deserialize(serd)
  local queue = deser_deque(serd.queue)
  local stack = {}
  for _, serd_que in ipairs(serd.stack) do
    table.insert(stack, deser_deque(serd_que))
  end

  return EventQueue._wrapped_class:new{queue = queue, stack = stack}
end

function EventQueue:context_changed(game_ctx)
  context_changed_deque(game_ctx, self.queue)

  for _, que in ipairs(self.stack) do
    context_changed_deque(game_ctx, que)
  end
end
-- endregion

function EventQueue:init()
  if self.queue == nil then
    self.queue = deque.new()
  end

  if self.stack == nil then
    self.stack = {}
  end
end

--- Enqueue the given event
-- @tparam Event event the event to enqueue
function EventQueue:enqueue(event)
  if #self.stack == 0 then
    self.queue:push_right(event)
  else
    self.stack[#self.stack]:push_right(event)
  end
end

--- Dequeue the oldest event in the queue
-- @treturn bool|Event false if nothing left, otherwise the event
function EventQueue:dequeue()
  if #self.stack == 0 then
    return self.queue:pop_left()
  else
    return self.stack[#self.stack]:pop_left()
  end
end

--- Peek the next event in the queue
-- @treturn bool|Event false if nothing left, otherwise the next event
function EventQueue:peek()
  if #self.stack == 0 then
    return self.queue:peek_left()
  else
    return self.stack[#self.stack]:peek_left()
  end
end

--- Push a new queue onto the stack.
function EventQueue:push()
  table.insert(self.stack, deque.new())
end

--- Pop the oldest queue off the stack. Errors if it
-- is not empty.
function EventQueue:pop()
  if #self.stack == 0 then
    error('nothing on the stack to pop!', 2)
  end

  if not self.stack[#self.stack]:is_empty() then
    error('top of stack is not empty!', 2)
  end

  self.stack[#self.stack] = nil
end

prototype.support(EventQueue, 'serializable')
return class.create('EventQueue', EventQueue)
