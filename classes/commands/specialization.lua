--- Acts as a command processor for specialization commands, delegating
-- to the specialization commands.
-- @classmod SpecializationCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

local specialization_pool = require('classes/specializations/specialization_pool')
local adventurers = require('functional/game_context/adventurers')

local word_wrap = require('functional/word_wrap')
local arg_parser = require('functional/arg_parser')

require('prototypes/command')
-- endregion

local SpecializationCommand = {}

function SpecializationCommand.priority() return 'explicit' end

local function is_command_or_alias(comm, first_arg)
  local stripped_of_slash = first_arg:sub(2)
  if comm:get_command() == stripped_of_slash then return true end

  local aliases = comm:get_aliases()

  for _,alias in ipairs(aliases) do
    if alias == stripped_of_slash then return true end
  end

  return false
end

local function print_help(comm)
  local str = comm:get_command()
  str = str:sub(1, 1):upper() .. str:sub(2)
  print('\27[K\r' .. str)

  word_wrap.print_wrapped(comm:get_long_description(), 2)
end

local function handle_command(comm, game_ctx, local_ctx, args)
  local succ, events = comm:parse(game_ctx, local_ctx, args)

  if not succ then
    print_help(comm)
    local_ctx.dirty = true
    return true, {}
  end

  return succ, events
end

local function print_specialization_info(game_ctx, local_ctx, args, spec)
  print('\27[K\r')

  local lore = false
  for k,v in ipairs(args) do
    if k ~= 1 then
      if v == '--lore' then
        lore = true
      else
        -- assume it's asking about a passive
        local tmp = v:sub(3):lower()
        for _, pass in ipairs(spec:get_specialization_passives()) do
          if pass:get_name():lower() == tmp then
            print('\27[2mPassive\27[0m: ' .. pass:get_name())
            word_wrap.print_wrapped(pass:get_long_description(), 2)
            return
          end
        end

        -- okay maybe it's asking about another specialization?
        if specialization_pool.specs_by_name[tmp] then
          local new_spec = specialization_pool.specs_by_name[tmp]
          -- strip this argument out

          local new_args = {}
          for k2,v2 in ipairs(args) do
            if k ~= k2 then
              table.insert(new_args, v2)
            end
          end

          return print_specialization_info(game_ctx, local_ctx, new_args, new_spec)
        end

        print('\27[41mUnknown parameter\27[49m: ' .. v)
      end
    end
  end


  local nm = spec:get_name()
  print(nm:sub(1, 1):upper() .. nm:sub(2))

  if lore then
    word_wrap.print_wrapped(spec:get_long_description(), 2)
    return
  end

  print('  ' .. spec:get_short_description())

  for _,comm in ipairs(spec:get_specialization_commands()) do
    print('  /' .. comm:get_command() .. ' - ' .. comm:get_short_description())
  end
  for _,pass in ipairs(spec:get_specialization_passives()) do
    print('  \27[2mPassive\27[0m: ' .. pass:get_name() .. ' - ' .. pass:get_short_description())
  end
end

function SpecializationCommand:parse(game_ctx, local_ctx, text)
  if game_ctx.in_setup_phase == nil or game_ctx.in_setup_phase then return false, nil end
  if text:sub(1, 1) ~= '/' then return false, nil end

  local my_advn = adventurers.get_local_adventurer(game_ctx, local_ctx)
  if not my_advn then return false, nil end

  local spec_name = my_advn.specialization
  if not spec_name then return false, nil end

  local parsed = arg_parser.parse_allow_quotes(text)

  local spec = specialization_pool:get_by_name(spec_name)
  local commands = spec:get_specialization_commands()

  if parsed[1] == '/specialization' then
    print_specialization_info(game_ctx, local_ctx, parsed, spec)
    return true, {}
  end

  for _, comm in ipairs(commands) do
    if is_command_or_alias(comm, parsed[1]) then
      return handle_command(comm, game_ctx, local_ctx, parsed)
    end
  end

  return false, nil
end

prototype.support(SpecializationCommand, 'command')
return class.create('SpecializationCommand', SpecializationCommand)
