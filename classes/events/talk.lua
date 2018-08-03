--- This event writes some text to the console
-- @classmod TalkEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

local adventurers = require('functional/game_context/adventurers')
local communication = require('functional/communication')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
-- endregion

local TalkEvent = {}

simple_serializer.inject(TalkEvent)

function TalkEvent:init()
  if not self.message then
    error('Talk events need a message!', 3)
  end

  if not self.id then
    error('Talk events need an id!', 3)
  end
end

function TalkEvent:process(game_ctx, local_ctx)
  io.write('\27[2K\r')

  if self.id ~= -1 then
    local advn = adventurers.get_adventurer(game_ctx, self.id)
    if not communication.local_can_hear(game_ctx, local_ctx, advn.id) then return end
    
    if advn then
      io.write('<' .. advn.name .. '>' .. ': ')
    else
      io.write('<Player ' .. self.id .. '>: ')
    end
  else
    io.write('\27[4m')
  end

  io.write(self.message .. '\27[0m\n')

  local_ctx.dirty = true
end

prototype.support(TalkEvent, 'event')
prototype.support(TalkEvent, 'serializable')
return class.create('TalkEvent', TalkEvent)
