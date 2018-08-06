--- Handles the /adventurers command
-- @classmod AdventurersCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

local adventurers = require('functional/game_context/adventurers')
local arg_parser = require('functional/arg_parser')
local inspect = require('functional/inspect').inspect

local TalkEvent = require('classes/events/talk')
local AdventurerEvent = require('classes/events/adventurer')

require('prototypes/command')
-- endregion

local AdventurersCommand = {}

function AdventurersCommand.priority() return 'explicit' end

local function print_help(text)
  io.write('\27[K\r' .. text .. '\n')
  print('/adventurers')
  print('  --list')
  print('    Lists all the adventurers and who they are attached to')
  print('  --add <name>')
  print('    Add a new adventurer with the given name')
  print('  --set <player id> <adventurer index>')
  print('    Set the adventurer of the given player to the given adventurer')
  print('  --unset <player id>')
  print('    Unattach the adventurer of the given player')
  print('  --info <adventurer index>')
  print('    Get additional information about a specific adventurer')
  print('  --help')
  print('    Prints this list')
  return true, {}
end

local function print_list(self, game_ctx, local_ctx, text)
  io.write('\27[K\r' .. text .. '\n')
  print('Adventurers:')
  if not game_ctx.adventurers then
    print('  None')
    return true, {}
  end

  for i, advn in ipairs(game_ctx.adventurers) do
    io.write('  ' .. i .. ': ' .. advn.name)
    if advn.attached_id then
      io.write(' [A-' .. advn.attached_id .. ']')
    end
    io.write('\n')
  end

  return true, {}
end

local function add(self, game_ctx, local_ctx, text, args)
  if #args < 2 then return print_help(text) end

  local name = ''
  for i,v in ipairs(args) do
    if i == 2 then name = v
    elseif i > 2 then name = name .. ' ' .. v
    end
  end

  if name == 'server' then
    print_help(text)
    return
  end

  local evnts = {}
  evnts[#evnts + 1] = TalkEvent:new{message = text, name = adventurers.get_local_name(game_ctx, local_ctx)}
  evnts[#evnts + 1] = AdventurerEvent:new{type = 'add', name = name}

  return true, evnts
end

local function set(self, game_ctx, local_ctx, text, args)
  if #args ~= 3 then return print_help(text) end
  if not game_ctx.adventurers then return print_help(text) end

  local player_id = tonumber(args[2])
  local adv_ind = tonumber(args[3])

  if not player_id or player_id < 0 then return print_help(text) end
  if not adv_ind or adv_ind < 1 or adv_ind > #game_ctx.adventurers then return print_help(text) end

  local adv_name = game_ctx.adventurers[adv_ind].name

  local evnts = {}
  evnts[#evnts + 1] = TalkEvent:new{message = text, name = adventurers.get_local_name(game_ctx, local_ctx)}
  evnts[#evnts + 1] = AdventurerEvent:new{type = 'set', player_id = player_id, adventurer_name = adv_name}

  return true, evnts
end

local function unset(self, game_ctx, local_ctx, text, args)
  if #args ~= 2 then return print_help(text) end

  local player_id = tonumber(args[2])

  if not player_id or player_id < 0 then return print_help(text) end

  local evnts = {}
  evnts[#evnts + 1] = TalkEvent:new{message = text, name = adventurers.get_local_name(game_ctx, local_ctx)}
  evnts[#evnts + 1] = AdventurerEvent:new{type = 'unset', player_id = player_id}

  return true, evnts
end

local function info(self, game_ctx, local_ctx, text, args)
  if #args ~= 2 then return print_help(text) end

  local advn_ind = tonumber(args[2])

  if not advn_ind or advn_ind < 1 or not game_ctx.adventurers or advn_ind > #game_ctx.adventurers then
    return print_help(text)
  end

  print('\27[K\r' .. text)
  print('Info on adventurer ' .. advn_ind)
  inspect(game_ctx.adventurers[advn_ind])
  local_ctx.dirty = true

  return true, {}
end

function AdventurersCommand:parse(game_ctx, local_ctx, text)
  if #text >= 12 and text:sub(1, 12) == '/adventurers' then
    local args = arg_parser.parse(text)
    if #args < 1 then
      return print_help(text)
    end

    local_ctx.dirty = true
    if args[1] == '--list' then return print_list(self, game_ctx, local_ctx, text)
    elseif args[1] == '--add' then return add(self, game_ctx, local_ctx, text, args)
    elseif args[1] == '--set' then return set(self, game_ctx, local_ctx, text, args)
    elseif args[1] == '--unset' then return unset(self, game_ctx, local_ctx, text, args)
    elseif args[1] == '--info' then return info(self, game_ctx, local_ctx, text, args)
    else return print_help(text) end
  end
  return false, nil
end

prototype.support(AdventurersCommand, 'command')
return class.create('AdventurersCommand', AdventurersCommand)
