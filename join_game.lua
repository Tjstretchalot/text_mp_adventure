--- Joins a game hosted by another player
-- region imports
local json = require('json')
local array = require('functional/array')
local inspect = require('functional/inspect').inspect
local console = require('console')
local socket = require('socket')
local file = require('functional/file')

local GameContext = require('classes/game_context')
local LocalContext = require('classes/local_context')
local EventQueue = require('classes/event_queue')
local ListenerProcessor = require('classes/listener_processor')
local CommandProcessor = require('classes/command_processor')
local ClientNetworking = require('classes/client_networking')

require('classes/local_context/serializers/all')
require('classes/game_context/serializers/all')
-- endregion

local host = console.string('Host?')
local port = console.numeric('Port?')

local client_networking = ClientNetworking:new{host = host, port = port}

local game_ctx, initial_events = client_networking:connect()

local local_ctx = LocalContext:new()
local event_queue = EventQueue:new()
local command_processor = CommandProcessor:new()
local list_processor = ListenerProcessor:new()

for _, event in ipairs(initial_events) do
  list_processor:invoke_pre_listeners(game_ctx, local_ctx, networking, event)
  event:process(game_ctx, local_ctx)
  list_processor:invoke_post_listeners(game_ctx, local_ctx, networking, event)
end

initial_events = nil

local succ, err = xpcall(function()
  require('main_input_loop')(game_ctx, local_ctx, event_queue, list_processor, command_processor, client_networking)
end, function(e)
  return {e, debug.traceback()}
end)

if not succ then
  print('Error: ' .. err[1])
  print(err[2])
end

client_networking:disconnect()
