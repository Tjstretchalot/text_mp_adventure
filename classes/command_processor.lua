--- This processes commands from the user
-- It maintains a list of commands, ordered by priority and then arbitrarily,
-- such that you can send commands to this and they are processed into one
-- or more events which can be added to the event queue
-- @classmod CommandProcessor

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')
local array = require('functional/array')

local commands = require('classes/commands/all')

local simple_serializer = require('utils/simple_serializer')
-- endregion

-- region sort commands
local command_priorities_ordered = { 'listener', 'explicit', 'implicit', 'generic' }
local sorted_commands = {}
for _, com in pairs(commands) do
  local compr = array.index_of(command_priorities_ordered, com.priority())

  local insert_index
  for i, v in ipairs(sorted_commands) do
    local vpr = array.index_of(command_priorities_ordered, v.priority())

    if vpr > compr then
      insert_index = i
      break
    end
  end

  if not insert_index then
    sorted_commands[#sorted_commands + 1] = com
  else
    table.insert(sorted_commands, insert_index, com)
  end
end
-- endregion

local CommandProcessor = {}

simple_serializer.inject(CommandProcessor)

--- Process the given message into a list of events
--
-- @tparam string message the message to process
-- @treturn {Event,...} the events that the given message caused
function CommandProcessor:process(game_ctx, local_ctx, message)
  for _, com in ipairs(sorted_commands) do
    local succ, events = com:parse(game_ctx, local_ctx, message)

    if succ then return events end
  end

  return {}
end

prototype.support(CommandProcessor, 'serializable')
return class.create('CommandProcessor', CommandProcessor)
