--- This is a debugger command; it runs the thing into the inspect function
-- @classmod InspectCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

local inspect = require('functional/inspect').inspect
local arg_parser = require('functional/arg_parser')

require('prototypes/command')

local TalkEvent = require('classes/events/talk')
-- endregion

local InspectCommand = {}

local function print_help(text)
  print('\27[K\r' .. text)
  print('/inspect')
  print('  <code literal> [--serialize]')
  print('    passes the code as a string literal to the inspect function')
  print('    if --serialize is added then it also serializes serializables')
  return true, {}
end

local function safish_inspect(game_ctx, local_ctx, text, code, serialize)
  print('\27[K\r' .. text)
  xpcall(function()
    loadstring('return function(game_ctx, local_ctx) require(\'functional/inspect\').inspect(' .. code .. ', ' .. tostring(serialize) .. ') end')()(game_ctx, local_ctx)
  end, function(err)
    print(err)
    print(debug.traceback())
  end)

  return true, {}
end

function InspectCommand.priority() return 'explicit' end

function InspectCommand:parse(game_ctx, local_ctx, text)
  if text:sub(1, 8) == '/inspect' then
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

prototype.support(InspectCommand, 'command')
return class.create('InspectCommand', InspectCommand)
