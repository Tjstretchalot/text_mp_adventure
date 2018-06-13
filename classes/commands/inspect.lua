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
  print('  <code literal>')
  print('    passes the code as a string literal to the inspect function')
  return true, {}
end

local function safish_inspect(game_ctx, local_ctx, text, code)
  print('\27[K\r' .. text)
  xpcall(function()
    loadstring('return function(game_ctx, local_ctx) require(\'functional/inspect\').inspect(' .. code .. ') end')()(game_ctx, local_ctx)
  end, function(err)
    print(err)
    print(debug.traceback())
  end)

  return true, {}
end

function InspectCommand.priority() return 'explicit' end

function InspectCommand:parse(game_ctx, local_ctx, text)
  if text:sub(1, 8) == '/inspect' then
    local args = arg_parser.parse(text)
    if #args ~= 1 then
      return print_help(text)
    end

    return safish_inspect(game_ctx, local_ctx, text, args[1])
  end

  return false, nil
end

prototype.support(InspectCommand, 'command')
return class.create('InspectCommand', InspectCommand)
