--- Runs a new local game

-- region imports
require('seed_random')
local json = require('json')
local array = require('functional/array')
local inspect = require('functional/inspect').inspect
local console = require('console')
local socket = require('socket')
local file = require('functional/file')

local GameContext = require('classes/game_context')
local LocalContext = require('classes/local_context')
local CommandProcessor = require('classes/command_processor')
local ListenerProcessor = require('classes/listener_processor')
local LocalNetworking = require('classes/local_networking')

require('classes/local_context/serializers/all')
require('classes/game_context/serializers/all')

local TimeEvent = require('classes/events/time')
local NewGameEvent = require('classes/events/new_game')
-- endregion

local game_ctx = GameContext:new()
local local_ctx = LocalContext:new({id = 0})
local listener_processor = ListenerProcessor:new()
local command_processor = CommandProcessor:new()
local_ctx.listener_processor = listener_processor

local networking = LocalNetworking:new()
networking:broadcast_events(game_ctx, local_ctx, { NewGameEvent:new() })

local last_updated_time = socket.gettime()*1000
local function update_time()
  local cur_time = socket.gettime() * 1000
  local delta_time = cur_time - last_updated_time
  if delta_time >= 1000 then
    networking:broadcast_events(game_ctx, local_ctx, { TimeEvent:new{ms = math.floor(delta_time)} })
    last_updated_time = cur_time
  end
end

local succ, err = xpcall(function()
  require('main_input_loop')(game_ctx, local_ctx, listener_processor, command_processor, networking, update_time)
end, function(e)
  return {e, debug.traceback()}
end)

if not succ then
  print('Error: ' .. err[1])
  print(err[2])
end

networking:disconnect()
