--- Get the current time of day
-- @classmod TimeCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/command')
-- endregion

local TimeCommand = {}

function TimeCommand.priority() return 'explicit' end

function TimeCommand:parse(game_ctx, local_ctx, text)
  if #text >= 5 and text:sub(1, 5) == '/time' then
    io.write('\27[K\r')
    if game_ctx.day.is_day then
      io.write('DAY ')
    else
      io.write('NIGHT ')
    end

    local seconds_til_change = math.floor(game_ctx.day.time_to_next_cycle_ms / 1000)
    io.write(tostring(seconds_til_change))
    io.write('s left\n')
    return true, {}
  end
  return false, nil
end

prototype.support(TimeCommand, 'command')
return class.create('TimeCommand', TimeCommand)
