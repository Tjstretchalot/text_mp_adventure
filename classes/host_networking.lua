--- Manages networking for the host
-- @classmod HostNetworking

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')
local socket = require('socket')
local deque = require('classes/dequeue/deque')
local json = require('json')
local array = require('functional/array')
local event_serializer = require('functional/event_serializer')
local event_queue = require('classes/event_queue')

local ClientConnectEvent = require('classes/events/client_connect')
local TalkEvent = require('classes/events/talk')
local ExitEvent = require('classes/events/exit')
local AssignLocalIDEvent = require('classes/events/assign_local_id')

require('prototypes/networking')
-- endregion

local HostNetworking = {}

function HostNetworking:init()
  if not self.port then
    error('Hosting a game requires that you specify a port!', 3)
  end

  self.server = socket.bind('*', self.port)
  self.server:settimeout(0) -- nonblocking

  self.ip, self.port = self.server:getsockname()

  --- Clients contain {socket=socket, id=number, current_read = string, remaining_sends=deque({line=string, start_index=ind},...)}
  self.clients = {}

  --- Contains just events.
  self.available_events = deque.new()

  --- Contains a queue and a stack
  self.event_queue = event_queue:new()
end

local function client_socket_error(self, client, err)
  local index = array.index_of(self.clients, client)
  client.socket = nil
  self:broadcast_events(game_ctx, local_ctx, { TalkEvent:new{message = 'Client ' .. client.id .. ' disconnected (' .. err .. ')', name = 'server'}, ExitEvent:new{id = client.id} })
end

local function read_from_client(self, game_ctx, local_ctx, cl)
  if not cl.socket then return end

  while true do
    local msg, err, partial = cl.socket:receive('*l')
    if not msg and err ~= 'timeout' then
      client_socket_error(self, cl, err)
      break
    elseif not msg then
      if partial then
        cl.current_read = cl.current_read .. partial
      end
      break
    else
      local full_msg = cl.current_read .. msg
      cl.current_read = ''

      local events_serd = json.decode(full_msg)
      for i, evnt_serd in ipairs(events_serd) do
        local event = event_serializer.deserialize(evnt_serd)
        event:context_changed(game_ctx)
        self:broadcast_events(game_ctx, local_ctx, {event})
        if event.class_name == 'ExitEvent' then
          cl.socket:close()
          cl.socket = nil
          return
        end
      end
    end
  end
end

local function try_complete_send(socket, msg)
  local exp_end = #msg
  local num_sent, err = socket:send(msg)

  while num_sent ~= exp_end do
    if num_sent == nil then
      return nil, err
    end

    num_sent, err = socket:send(msg, num_sent)
  end

  return exp_end, nil
end

local function try_accept_client(self, game_ctx, local_ctx)
  local client, err = self.server:accept()

  if not client then
    if err == 'timeout' then return end

    self:broadcast_events(game_ctx, local_ctx, { TalkEvent:new{message = 'Server socket died; err = ' .. err, name = 'server'}, ExitEvent:new() })
  end

  print('Client connecting..')

  client:settimeout(10)

  local succ, err = try_complete_send(client, json.encode(game_ctx:serialize()) .. '\n')
  if not succ then
    print('Client connect failed on sync game context (' .. err .. ')')
    client:close()
    return
  end

  local new_id = (game_ctx.client_id_counter or 0) + 1
  game_ctx.client_id_counter = new_id

  local evnt = AssignLocalIDEvent:new{id = new_id}

  local succ, err = try_complete_send(client, json.encode({event_serializer.serialize(evnt)}) .. '\n')
  if not succ then
    print('Client connect failed on assign local id (' .. err .. ')')
    client:close()
    return
  end

  client:settimeout(0)
  self.clients[#self.clients + 1] = { socket = client, id = new_id, current_read = '', remaining_sends = deque.new() }

  self:broadcast_events(game_ctx, local_ctx, { ClientConnectEvent:new{id = new_id} })

  print('Success!')
end

local function try_send_client(self, client)
  if not client.socket then return true, nil end

  local msg = client.remaining_sends:pop_left()
  while msg do
    local written_to, err, maybe_written_to = client.socket:send(msg.line, msg.start_index)

    if not written_to then
      if err == 'timeout' then
         msg.start_index = maybe_written_to
         client.remaining_sends:push_left(msg)
         break
      end
      return nil, err
    end

    if written_to ~= #msg.line then
      msg.start_index = written_to
      client.remaining_sends:push_left(msg)
      break
    end

    msg = client.remaining_sends:pop_left()
  end
  return true, nil
end

--- Takes the available events and pushes them onto the event queue
-- While doing so it serializes and pushes them onto the remaining
-- sends for each client.
local function process_local_queue(self, game_ctx, local_ctx)
  local event = self.available_events:pop_left()
  while event do
    self.event_queue:enqueue(event)
    local serd = json.encode({event_serializer.serialize(event)}) .. '\n'
    for _, cl in ipairs(self.clients) do
      cl.remaining_sends:push_right({line = serd, start_index = 1})
    end
    event = self.available_events:pop_left()
  end
end

--- queues the signal to start processing an event to all clients
local function send_signal_event_start(self)
  local serd = '[{"signal":true,"type":"start"}]\n'
  for _, cl in ipairs(self.clients) do
    cl.remaining_sends:push_right({line = serd, start_index = 1})
  end
end

--- queues the signal that the server finished processing an event to all clients
local function send_signal_event_finished(self)
  local serd = '[{"signal":true,"type":"finish"}]\n'
  for _, cl in ipairs(self.clients) do
    cl.remaining_sends:push_right({line = serd, start_index = 1})
  end
end

--- Processes at most one event in the synced queue (the event_queue)
local function process_synced_queue(self, game_ctx, local_ctx)
  local event = self.event_queue:dequeue()
  if not event then
    if #self.event_queue.stack == 0 then return end -- nothing left

    -- event queue top of stack empty -> pop
    send_signal_event_finished(self)
    self.event_queue:pop()
  else
    -- event queue top of stack not empty -> process next event
    send_signal_event_start(self)
    self.event_queue:push()
    local_ctx.listener_processor:invoke_pre_listeners(game_ctx, local_ctx, self, event)
    event:process(game_ctx, local_ctx, self)
    local_ctx.listener_processor:invoke_post_listeners(game_ctx, local_ctx, self, event)
  end
end

local function write_to_client(self, cl)
  local succ, err = try_send_client(self, cl)
  if not succ then
    client_socket_error(self, cl, err)
  end
end

local function clean_clients(self)
  for ind = #self.clients, 1, -1 do
    if not self.clients[ind].socket then
      table.remove(self.clients, ind)
    end
  end
end

--- Process the queues.
-- @treturn boolean true if successfully processed everything, false otherwise
local function process_queues(self, game_ctx, local_ctx)
  local start_time_seconds = socket.gettime()
  while #self.event_queue.stack ~= 0
    or not self.event_queue.queue:is_empty()
    or not self.available_events:is_empty() do
    process_local_queue(self, game_ctx, local_ctx)
    process_synced_queue(self, game_ctx, local_ctx)

    local delta_time_seconds = socket.gettime() - start_time_seconds
    if delta_time_seconds > 0.05 then
      print('[HostNetworking]: Unable to process event queue within 50ms! Yielding to prevent timeouts..')
      return false
    end
  end

  return true
end

function HostNetworking:update(game_ctx, local_ctx)
  -- Read from clients
  for _, cl in ipairs(self.clients) do
    read_from_client(self, game_ctx, local_ctx, cl)
  end
  clean_clients(self)

  -- Clear the queue out
  local success = process_queues(self, game_ctx, local_ctx)

  if success then
    -- Success tells is that it is safe to accept new clients. We can't
    -- accept new clients while we're behind
    try_accept_client(self, game_ctx, local_ctx)
  end

  -- Write to clients
  for _, cl in ipairs(self.clients) do
    write_to_client(self, cl)
  end
  clean_clients(self)
end

function HostNetworking:broadcast_events(game_ctx, local_ctx, events)
  for _, evnt in ipairs(events) do
    self.available_events:push_right(evnt)
  end
end

function HostNetworking:disconnect(game_ctx, local_ctx)
  self.server:close()
  self.server = nil
end

prototype.support(HostNetworking, 'networking')
return class.create('HostNetworking', HostNetworking)
