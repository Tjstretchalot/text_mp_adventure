--- Handles the /locations command
-- @classmod LocationsCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

local adventurers = require('functional/game_context/adventurers')
local locations = require('functional/game_context/locations')
local arg_parser = require('functional/arg_parser')
local inspect = require('functional/inspect').inspect

local TalkEvent = require('classes/events/talk')
local LocationEvent = require('classes/events/location')

require('prototypes/command')
-- endregion

local LocationsCommand = {}

local function print_help(text)
  print('\27[K\r' .. text)
  print('/locations')
  print('  --list')
  print('    List all of the locations')
  print('  --inspect <loc_name>')
  print('    Inspect the location with the given name')
  print('  --add \'<name>\' \'<description>\'')
  print('    Add a location with the given description. Note the quotes.')
  return true, {}
end

local function print_list(game_ctx, local_ctx, text, args)
  print('\27[K\r' .. text)
  print('Locations:')

  if not game_ctx.locations then
    print('  None')
    return true, {}
  end

  for nm, loc in pairs(game_ctx.locations) do
    print('  \'' .. tostring(nm) .. '\'')
  end
  return true, {}
end

local function handle_inspect(game_ctx, local_ctx, text, args)
  print('\27[K\r' .. text)
  print('Inspecting locations[\'' .. args[3] .. '\']')
  if not game_ctx.locations then
    print ('  locations is nil')
    return true, {}
  end

  inspect(game_ctx.locations[args[3]])
  return true, {}
end

local function handle_add(game_ctx, local_ctx, text, args)
  local loc_name = args[3]
  local loc_desc = args[4]

  if #loc_name < 3 then
    print('\27[K\r' .. text)
    print('Location name too short')
    return true, {}
  end

  if #loc_desc < 3 then
    print('\27[K\r' .. text)
    print('Location description too short')
    return true, {}
  end

  if game_ctx.locations and game_ctx.locations[loc_name] then
    print('\27[K\r' .. text)
    print('Already have a location by that name (use --list to list)')
    return true, {}
  end

  local evnts = {}
  evnts[#evnts + 1] = TalkEvent:new{message = text, name = adventurers.get_local_name(game_ctx, local_ctx)}
  evnts[#evnts + 1] = LocationEvent:new{type = 'new', location = { name = loc_name, description = loc_desc } }
  return true, evnts
end

function LocationsCommand:priority() return 'explicit' end

function LocationsCommand:parse(game_ctx, local_ctx, text)
  if #text >= 10 and text:sub(1, 10) == '/locations' then
    local args, err = arg_parser.parse_allow_quotes(text)
    if not args then
      print('\27[K\r' .. text .. '\nError parsing arguments: ' .. err)
      return true, {}
    end

    if #args < 2 then
      return print_help(text)
    end

    if args[2] == '--list' then return print_list(game_ctx, local_ctx, text, args)
    elseif args[2] == '--inspect' and #args == 3 then return handle_inspect(game_ctx, local_ctx, text, args)
    elseif args[2] == '--add' and #args == 4 then return handle_add(game_ctx, local_ctx, text, args) end

    return print_help(text)
  end

  return false, nil
end

prototype.support(LocationsCommand, 'command')
return class.create('LocationsCommand', LocationsCommand)
