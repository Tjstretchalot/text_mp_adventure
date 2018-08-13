--- This is the local event to determine if a system message will
-- be recieved properly
-- @classmod LocalSystemMessageEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
-- endregion

local LocalSystemMessageEvent = {}

simple_serializer.inject(LocalSystemMessageEvent)

function LocalSystemMessageEvent:init()
  if type(self.adventurer_ind) ~= 'number' then
    error('LocalSystemMessageEvent is missing adventurer_ind (the index in adventurers for who will recieve the event)', 3)
  end

  if type(self.message) ~= 'string' then
    error('LocalSystemMessageEvent require a message', 3)
  end

  if type(self.result) == 'nil' then
    self.result = true
  elseif type(self.result) ~= 'boolean' then
    error('LocalSystemMessageEvent result is set to bad type (nil, false, or true expected, got ' .. type(self.result) .. ')', 3)
  end
end

function LocalSystemMessageEvent:process(game_ctx, local_ctx)
end

prototype.support(LocalSystemMessageEvent, 'event')
prototype.support(LocalSystemMessageEvent, 'serializable')
return class.create('LocalSystemMessageEvent', LocalSystemMessageEvent)
