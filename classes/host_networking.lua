--- Manages networking for the host
-- @classmod HostNetworking

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')
local socket = require('socket')
local deque = require('classes/dequeue/deque')
local json = require('json')
local array = require('functional/array')

local ClientConnectEvent = require('classes/events/client_connect')
local TalkEvent = require('classes/events/talk')
local ExitEvent = require('classes/events/exit')
local AssignLocalIDEvent = require('classes/events/assign_local_id')

local Events = require('classes/events/all')

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
end

local function client_socket_error(self, client, err)
  local index = array.index_of(self.clients, client)
  table.remove(self.clients, index)
  self:broadcast_events(game_ctx, local_ctx, { TalkEvent:new{message = 'Client ' .. client.id .. ' disconnected (' .. err .. ')', id = -1}, ExitEvent:new{id = client.id} })
end

local function handle_client(self, game_ctx, local_ctx, event_queue, cl)
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
        local event = Events[evnt_serd[1]].deserialize(evnt_serd[2])
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

local function try_accept_client(self, game_ctx, local_ctx, event_queue)
  local client, err = self.server:accept()

  if not client then
    if err == 'timeout' then return end

    self:broadcast_events(game_ctx, local_ctx, { TalkEvent:new{message = 'Server socket died; err = ' .. err, id = -1}, ExitEvent:new() })
  end

  print('Client connecting..')

  client:settimeout(10)

  local succ, err = try_complete_send(client, json.encode(game_ctx:serialize()) .. '\n')
  if not succ then
    print('Client connect failed on sync game context (' .. err .. ')')
    client:close()
    return
  end

  local new_id
  if #self.clients > 0 then
    new_id = self.clients[#self.clients].id + 1
  else
    new_id = 1
  end

  local evnt = AssignLocalIDEvent:new{id = new_id}

  local succ, err = try_complete_send(client, json.encode({{evnt.class_name, evnt:serialize()}}) .. '\n')
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

function HostNetworking:update(game_ctx, local_ctx, event_queue)
  local disconnected_inds = {}
  for _, cl in ipairs(self.clients) do
    handle_client(self, game_ctx, local_ctx, event_queue, cl)
  end

  try_accept_client(self, game_ctx, local_ctx, event_queue)

  local event = self.available_events:pop_left()
  while event do
    event_queue:enqueue(event)
    local serd = json.encode({{ event.class_name, event:serialize() }}) .. '\n'
    for _, cl in ipairs(self.clients) do
      cl.remaining_sends:push_right({line = serd, start_index = 1})
    end
    event = self.available_events:pop_left()
  end

  local cur_index = 1
  while cur_index <= #self.clients do
    local cl = self.clients[cur_index]
    if not cl.socket then
      table.remove(self.clients, cur_index)
    else
      local succ, err = try_send_client(self, cl)
      if not succ then
        client_socket_error(self, cl, err)
      else
        cur_index = cur_index + 1
      end
    end
  end
end

local function handle_exit_event(self, evnt)
  if evnt.id then
    local index_in_clients
    for i=1, #self.clients do
      if self.clients[i].id == evnt.id then
        index_in_clients = i
        break
      end
    end
    if index_in_clients then
      self.clients[index_in_clients].socket:close()
      table.remove(self.clients, index_in_clients)
    end
  end
end

function HostNetworking:broadcast_events(game_ctx, local_ctx, events)
  for _, evnt in ipairs(events) do
    self.available_events:push_right(evnt)
  end
end

function HostNetworking:disconnect(game_ctx, local_ctx, event_queue)
  self.server:close()
  self.server = nil
end

prototype.support(HostNetworking, 'networking')
return class.create('HostNetworking', HostNetworking)
