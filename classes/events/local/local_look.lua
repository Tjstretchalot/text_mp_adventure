--- This helps us build the look message. Ordering of listeners
-- is likely to be important. You can control indentation & word
-- wrap will be done on the client
-- @classmod LocalLookEvent

-- region imports
local table = table
local type = type

local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
-- endregion

local LocalLookEvent = {}

simple_serializer.inject(LocalLookEvent)

function LocalLookEvent:init()
  if type(self.adventurer_ind) ~= 'number' then
    error('LocalLookEvent is missing adventurer_ind (the index in adventurers)', 3)
  end

  if self.message ~= nil then
    error('LocalLookEvent creates the message - you don\'t pass it one!', 3)
  end

  self.message = {}

  if type(self.result) == 'nil' then
    self.result = true
  elseif type(self.result) ~= 'boolean' then
    error('LocalLookEvent result is set to bad type (nil, false, or true expected, got ' .. type(self.result) .. ')', 3)
  end

  if type(self.fail_reason) ~= 'nil' then
    error('LocalLookEvent fail_reason should be set by the listeners!', 3)
  end
end

--- Utility function for appending a line
-- @tparam string line the line to append
function LocalLookEvent:append_line(line)
  self:append_indented_line(line, 0)
end

--- Utility function for appending a line with an indent
-- @tparam string line the line to append
-- @tparam number indent the number of spaces to prepend
function LocalLookEvent:append_indented_line(line, indent)
  if #self.message > 0 then table.insert(self.message, { text = '\n', indent = indent }) end
  table.insert(self.message, { text = line, indent = indent })
end

function LocalLookEvent:process(game_ctx, local_ctx)
end

prototype.support(LocalLookEvent, 'event')
prototype.support(LocalLookEvent, 'serializable')
return class.create('LocalLookEvent', LocalLookEvent)
