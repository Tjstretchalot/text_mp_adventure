--- This event shuts down the program
-- It does this through raising an error. Note: Some places handle
-- this event specially by checking the class_name (especially networking)
-- @classmod ExitEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
-- endregion

local ExitEvent = {}

simple_serializer.inject(ExitEvent)

function ExitEvent:process(game_ctx, local_ctx)
  if self.id == 0 or self.id == nil or self.id == local_ctx.id then
    error('ExitEvent:process, self.id = ' .. self.id)
  end
end

prototype.support(ExitEvent, 'event')
prototype.support(ExitEvent, 'serializable')
return class.create('ExitEvent', ExitEvent)
