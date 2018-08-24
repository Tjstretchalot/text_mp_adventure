--- This command moves the adventurer through the AdventurerEvent
-- @classmod MoveCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/command')

local arg_parser = require('functional/arg_parser')
local adventurers = require('functional/game_context/adventurers')

local MoveCommandEvent = require('classes/events/move_command')
-- endregion

local MoveCommand = {}

function MoveCommand:print_help()
  print('/move location')
  print('  location - the name of the location you want to move to')
end

function MoveCommand.priority() return 'explicit' end

function MoveCommand:parse(game_ctx, local_ctx, text)
  if game_ctx.in_setup_phase then return false, nil end

  if (#text >= 3 and text:sub(1, 3) == '/go') or (#text >= 5 and text:sub(1, 5) == '/move') then
    local parsed = arg_parser.parse_allow_quotes(text)

    print('\r' .. text)
    if #parsed == 1 then
      self:print_help()
      return true, {}
    end

    local loc = nil
    local try = false
    for k, v in ipairs(parsed) do
      if k ~= 1 then
        if v == '--try' then
          try = true
        else
          if loc then
            print('Unknown argument: ' .. tostring(v))
            self:print_help()
            return true, {}
          end

          loc = v
        end
      end
    end

    if not loc then
      print('Missing location!')
      self:print_help()
      return true, {}
    end

    if not game_ctx.locations[loc] then
      print('Unknown location: ' .. loc)
      self:print_help()
      return true, {}
    end

    local loc_nm = adventurers.get_local_name(game_ctx, local_ctx)
    if not loc_nm then
      print('Missing local adventurer')
      return true, {}
    end

    return true, { MoveCommandEvent:new{ adventurer_name = loc_nm, destination = loc } }
  end

  return false, nil
end

prototype.support(MoveCommand, 'command')
return class.create('MoveCommand', MoveCommand)
