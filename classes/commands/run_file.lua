--- Much like the inspect command this allows for easier debugging
-- The file should be structured like
-- local game_ctx, local_ctx = ...
-- <stuff here>
-- return <thing to inspect>
-- @classmod RunFileCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

local inspect = require('functional/inspect').inspect
local arg_parser = require('functional/arg_parser')

require('prototypes/command')

local TalkEvent = require('classes/events/talk')
-- endregion

local RunFileCommand = {}

local function print_help(text)
  print('\27[K\r' .. text)
  print('/runfile')
  print('  <file path> [--serialize]')
  print('    passes the code in the file to the inspect function')
  print('    if --serialize is added then it also serializes serializables')
  return true, {}
end

local function safish_inspect(game_ctx, local_ctx, text, file, serialize)
  print('\27[K\r' .. text)
  xpcall(function()
    local result = assert(loadfile(file))
    local stuff = result(game_ctx, local_ctx)
    inspect(stuff, serialize)
  end, function(err)
    print(err)
    print(debug.traceback())
  end)

  return true, {}
end

function RunFileCommand.priority() return 'explicit' end

function RunFileCommand:parse(game_ctx, local_ctx, text)
  if text:sub(1, 8) == '/runfile' then
    local args, err = arg_parser.parse_allow_quotes(text)
    if not args then
      print('\27[K\r' .. text)
      print('  Error parsing arguments: ' .. err)
      return true, {}
    end

    if #args < 2 or #args > 3 then
      return print_help(text)
    end

    local serialize = false
    if #args == 3 then
      if args[3] == '--serialize' then
        serialize = true
      else
        print_help(text)
      end
    end

    return safish_inspect(game_ctx, local_ctx, text, args[2], serialize)
  end

  return false, nil
end

prototype.support(RunFileCommand, 'command')
return class.create('RunFileCommand', RunFileCommand)
