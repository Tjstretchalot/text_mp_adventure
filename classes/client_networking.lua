--- Handles the client networking
-- @classmod ClientNetworking

-- region imports
local json = require('json')
local socket = require('socket')

local class = require('classes/class')
local prototype = require('prototypes/prototype')

local deque = require('classes/dequeue/deque')

require('prototypes/networking')

local GameContext = require('classes/game_context')
local Events = require('classes/events/all')

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

  local initial_sync_events_serd_encoded, err = self.server:receive('*l')
  if not initial_sync_events_serd_encoded then
    print('Failed to connect on receive initial sync events (err = ' .. err .. ')')
    return
  end
  local initial_sync_events_serd = json.decode(initial_sync_events_serd_encoded)
  local initial_sync_events = {}

  for i, serd in ipairs(initial_sync_events_serd) do
    initial_sync_events[i] = Events[serd[1]].deserialize(serd[2])
  end

  self.server:settimeout(0)
  return game_ctx, initial_sync_events
end

local function parse_from_server(self, game_ctx, local_ctx, event_queue, msg)
  local events_serd = json.decode(msg)

  for _, serd in ipairs(events_serd) do
    event_queue:enqueue(Events[serd[1]].deserialize(serd[2]))
  end
end

local function try_read_from_server(self, game_ctx, local_ctx, event_queue)
  while true do
    local from_server, err, partial_read = self.server:receive('*l')

    if from_server then
      local full_msg = self.current_receive .. from_server
      self.current_receive = ''
      parse_from_server(self, game_ctx, local_ctx, event_queue, full_msg)
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

function ClientNetworking:update(game_ctx, local_ctx, event_queue)
  local succ, err = try_read_from_server(self, game_ctx, local_ctx, event_queue)
  if not succ then
    error('Failed to read from server (err = ' .. err .. ')')
  end

  succ, err = try_send_to_server(self)
  if not succ then
    error('Failed to write to server (err = ' .. err .. ')')
  end
end

function ClientNetworking:broadcast_events(game_ctx, local_ctx, events)
  local serd = {}
  for i, ev in ipairs(events) do
    serd[i] = { ev.class_name, ev:serialize() }
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
