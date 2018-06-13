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
local CommandProcessor = require('classes/command_processor')
local ListenerProcessor = require('classes/listener_processor')
local HostNetworking = require('classes/host_networking')

require('classes/local_context/serializers/all')

-- endregion

local game_ctx, event_queue

local local_ctx = LocalContext:new({id = 0})
local listener_processor = ListenerProcessor:new()
local command_processor = CommandProcessor:new()

-- region loading helpers
local function create_new()
  game_ctx = GameContext:new()
  event_queue = EventQueue:new()
end

local function load()
  local file = io.open('saves/game_context.json')
  game_ctx = GameContext.deserialize(json.decode(file:read('*all')))
  file:close()

  file = io.open('saves/event_queue.json')
  event_queue = EventQueue.deserialize(json.decode(file:read('*all')))
  file:close()
end

local function create_or_load()
  local choice = console.yesno('Load existing world?')
  if choice then
    load()
  else
    create_new()
  end
end
-- endregion
-- region save helper
local function save()
  local dirs = file.scandir('.', false, true)
  if not array.contains(dirs, 'saves') then
    os.execute('mkdir saves')
  end

  local file = io.open('saves/game_context.json', 'w')
  file:write(json.encode(game_ctx:serialize()))
  file:close()

  file = io.open('saves/event_queue.json', 'w')
  file:write(json.encode(event_queue:serialize()))
  file:close()
end
-- endregion

create_or_load()

local port = console.numeric('What port? Use 0 for the os to choose: ')
local host_networking = HostNetworking:new{port = port}

print('Bound on ' .. host_networking.ip .. ':' .. host_networking.port)

local succ, err = xpcall(function()
  require('main_input_loop')(game_ctx, local_ctx, event_queue, listener_processor, command_processor, host_networking)
end, function(e)
  return {e, debug.traceback()}
end)

-- region cleanup
if not succ then
  print('Error: ' .. err[1])
  print(err[2])
end
-- endregion

host_networking:disconnect()

io.write('\27[2k\rSaving...\n')
save()
