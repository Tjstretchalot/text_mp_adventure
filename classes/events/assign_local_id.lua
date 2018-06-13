--- Assigns the local id
-- This is only used when the host is first syncing a client
-- @classmod AssignLocalIDEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
-- endregion

local AssignLocalIDEvent = {}

simple_serializer.inject(AssignLocalIDEvent)

function AssignLocalIDEvent:init()
  if not self.id then
    error('No id set to assign!', 3)
  end
end

function AssignLocalIDEvent:process(game_ctx, local_ctx)
  local_ctx.id = self.id
end

prototype.support(AssignLocalIDEvent, 'event')
prototype.support(AssignLocalIDEvent, 'serializable')
return class.create('AssignLocalIDEvent', AssignLocalIDEvent)
