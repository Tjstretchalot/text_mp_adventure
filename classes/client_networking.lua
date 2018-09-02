--- Handles the client networking
-- @classmod ClientNetworking

-- region imports
local json = require('json')
local socket = require('socket')

local class = require('classes/class')
local prototype = require('prototypes/prototype')
local event_serializer = require('functional/event_serializer')

local deque = require('classes/dequeue/deque')

require('prototypes/networking')

local GameContext = require('classes/game_context')
local EventQueue = require('classes/event_queue')

local ExitEvent = require('classes/events/exit')
-- endregion

local ClientNetworking = {}

function ClientNetworking:init()
  if not self.host then
    error('ClientNetworking requires a host!', 3)
  end

  if not self.port then
    error('ClientNetworking requires a port!', 3)
  end

  -- Contains {line = string, start_index = number}
  self.awaiting_send = deque.new()
  self.current_receive = ''

  self.event_queue = EventQueue:new()
  self.raw_queue = deque.new()
end

--- Connect to the host and port set via the constructor
-- This is the only blocking networking section
-- @treturn GameContext the state of the game
-- @treturn {Event,...} events that need to be enqueued immediately
function ClientNetworking:connect()
  local socket, err = socket.connect(self.host, self.port)
  if not socket then error('Failed to connect (err = ' .. err .. ')') end
  self.server = socket
  self.server:settimeout(10)

  -- receive full game context
  local game_ctx_serd_encoded, err = self.server:receive('*l')
  if not game_ctx_serd_encoded then
    print('Failed to connect on receive game state (err = ' .. err .. ')')
    return
  end
  local game_ctx_serd = json.decode(game_ctx_serd_encoded)
  local game_ctx = GameContext.deserialize(game_ctx_serd)
  game_ctx:context_changed(game_ctx)

  local initial_sync_events_serd_encoded, err = self.server:receive('*l')
  if not initial_sync_events_serd_encoded then
    print('Failed to connect on receive initial sync events (err = ' .. err .. ')')
    return
  end
  local initial_sync_events_serd = json.decode(initial_sync_events_serd_encoded)
  local initial_sync_events = {}

  for i, serd in ipairs(initial_sync_events_serd) do
    initial_sync_events[i] = event_serializer.deserialize(serd)
  end

  self.server:settimeout(0)
  return game_ctx, initial_sync_events
end

local function parse_from_server(self, game_ctx, local_ctx, msg)
  local events_serd = json.decode(msg)

  for _, serd in ipairs(events_serd) do
    if serd.signal then
      self.raw_queue:push_right(serd.type)
    else
      local event = event_serializer.deserialize(serd)
      event:context_changed(game_ctx)

      self.raw_queue:push_right(event)
    end
  end
end

local function try_read_from_server(self, game_ctx, local_ctx)
  while true do
    local from_server, err, partial_read = self.server:receive('*l')

    if from_server then
      local full_msg = self.current_receive .. from_server
      self.current_receive = ''
      parse_from_server(self, game_ctx, local_ctx, full_msg)
    elseif err == 'timeout' then
      if partial_read and partial_read ~= '' then
        self.current_receive = self.current_receive .. partial_read
      end
      return true, nil
    else
      return false, err
    end
  end
end

local function try_send_to_server(self)
  local msg = self.awaiting_send:pop_left()
  while msg do
    local end_ind, err, partial_end_ind = self.server:send(msg.line, msg.start_index)

    if err == 'timeout' or end_ind < #msg.line then
      msg.start_index = end_ind or partial_end_ind
      self.awaiting_send:push_left(msg)
      return true, nil
    end

    if not end_ind then
      return false, err
    end

    msg = self.awaiting_send:pop_left()
  end
  return true, nil
end

local function process_queues(self, game_ctx, local_ctx)
  while true do
    local raw = self.raw_queue:pop_left()

    if not raw then
      return -- wait for more stuff to do
    elseif raw == 'start' then
      local event = self.event_queue:dequeue()
      self.event_queue:push()
      local_ctx.listener_processor:invoke_pre_listeners(game_ctx, local_ctx, self, event)
      event:process(game_ctx, local_ctx, self)
      local_ctx.listener_processor:invoke_post_listeners(game_ctx, local_ctx, self, event)
    elseif raw == 'finish' then
      self.event_queue:pop()
    else
      self.event_queue:enqueue(raw)
    end
  end
end

function ClientNetworking:update(game_ctx, local_ctx)
  local succ, err = try_read_from_server(self, game_ctx, local_ctx)
  if not succ then
    error('Failed to read from server (err = ' .. err .. ')')
  end

  succ, err = try_send_to_server(self)
  if not succ then
    error('Failed to write to server (err = ' .. err .. ')')
  end

  process_queues(self, game_ctx, local_ctx)
end

function ClientNetworking:broadcast_events(game_ctx, local_ctx, events)
  local serd = {}
  for i, ev in ipairs(events) do
    serd[i] = event_serializer.serialize(ev)
  end

  local serd_encoded = json.encode(serd) .. '\n'
  self.awaiting_send:push_right({ line = serd_encoded, start_index = 1 })
end

function ClientNetworking:disconnect(game_ctx, local_ctx, event_queue)
  self.server:close()
  self.server = nil
end

prototype.support(ClientNetworking, 'networking')
return class.create('ClientNetworking', ClientNetworking)
