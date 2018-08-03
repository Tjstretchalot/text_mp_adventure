--- This event is called when we have just started hosting a new game.
-- It is particularly helpful for setting up the game context.
-- @classmod NewGameEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
-- endregion

local NewGameEvent = {}

simple_serializer.inject(NewGameEvent)

function NewGameEvent:init()
end

function NewGameEvent:process()
end

prototype.support(NewGameEvent, 'event')
prototype.support(NewGameEvent, 'serializable')
return class.create('NewGameEvent', NewGameEvent)
