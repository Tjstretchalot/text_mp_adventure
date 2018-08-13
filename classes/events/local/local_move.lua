--- This event is used for signalling if a movement is
-- successful. The 'local' prefix indicates its meant to
-- be fired by the host.
-- @classmod LocalMoveEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
-- endregion

local LocalMoveEvent = {}

simple_serializer.inject(LocalMoveEvent)

function LocalMoveEvent:init()
  if type(self.adventurer_ind) ~= 'number' then
    error('LocalMoveEvent is missing adventurer_ind (the index in adventurers)', 3)
  end

  if type(self.destination) ~= 'string' then
    error('LocalMoveEvent is missing destination (string name of dest location)', 3)
  end

  if type(self.result) == 'nil' then
    self.result = true
  elseif type(self.result) ~= 'boolean' then
    error('LocalMoveEvent result is set to bad type (nil, false, or true expected, got ' .. type(self.result) .. ')', 3)
  end

  if type(self.fail_reason) ~= 'nil' then
    error('LocalMoveEVent fail_reason should be set by the listeners!', 3)
  end
end

function LocalMoveEvent:process(game_ctx, local_ctx)
end

prototype.support(LocalMoveEvent, 'event')
prototype.support(LocalMoveEvent, 'serializable')
return class.create('LocalMoveEvent', LocalMoveEvent)
