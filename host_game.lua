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
require('classes/game_context/serializers/all')

local TimeEvent = require('classes/events/time')
local NewGameEvent = require('classes/events/new_game')

-- endregion

local game_ctx, event_queue

local local_ctx = LocalContext:new({id = 0})
local listener_processor = ListenerProcessor:new()
local command_processor = CommandProcessor:new()

local_ctx.listener_processor = listener_processor

-- region loading helpers
local function create_new()
  game_ctx = GameContext:new()
  event_queue = EventQueue:new()
  event_queue:enqueue(NewGameEvent:new())
end

local function load()
  local file = io.open('saves/game_context.json')
  game_ctx = GameContext.deserialize(json.decode(file:read('*all')))
  file:close()

  file = io.open('saves/event_queue.json')
  event_queue = EventQueue.deserialize(json.decode(file:read('*all')))
  file:close()

  game_ctx:context_changed(game_ctx)
  event_queue:context_changed(game_ctx)
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
-- region lock helpers
local function try_get_lock()
  local succ, err = os.rename('saves/.lock', 'saves/.lock')
  if succ then
    error('Could not create lock file (already exists)! If no server is running, delete saves/.lock')
  end

  local hndl, err = io.open('saves/.lock', 'w')
  if not hndl then error('Failed to create lock file saves/.lock: ' .. tostring(err)) end
  hndl:close()
end

local function release_lock()
  local succ, err = os.rename('saves/.lock', 'saves/.lock')
  if not succ then
    print('Lock file was deleted! We will try to save after user input..')
    os.execute('pause')
  end

  local succ, err = os.remove('saves/.lock')
  if not succ then
    print('Failed to delete lock file! We will try to save after user input..')
    os.execute('pause')
  end
end
-- endregion
try_get_lock()
create_or_load()

local port = console.numeric('What port? Use 0 for the os to choose: ')
local host_networking = HostNetworking:new{port = port}

print('Bound on ' .. host_networking.ip .. ':' .. host_networking.port)

local last_updated_time = socket.gettime()*1000
local function update_time()
  local cur_time = socket.gettime() * 1000
  local delta_time = cur_time - last_updated_time
  if delta_time >= 1000 then
    host_networking:broadcast_events(game_ctx, local_ctx, { TimeEvent:new{ms = math.floor(delta_time)} })
    last_updated_time = cur_time
  end
end

local succ, err = xpcall(function()
  require('main_input_loop')(game_ctx, local_ctx, event_queue, listener_processor, command_processor, host_networking, update_time)
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

release_lock()
io.write('\27[2k\rSaving...\n')
save()
