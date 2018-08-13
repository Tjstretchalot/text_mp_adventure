--- A system message is a response from the system about the success or
-- failure of an event or an action taking place (such as day night cycling).
-- It differents from a talk event with the 'server' keyword in that those
-- can be used to communicate with everyone for meta-events (client connected
-- or disconnected, server shutting down, etc)
-- @classmod SystemMessageEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
local word_wrap = require('functional/word_wrap')

local adventurers = require('functional/game_context/adventurers')
-- endregion

local SystemMessageEvent = {}

simple_serializer.inject(SystemMessageEvent)

function SystemMessageEvent:init()
  if type(self.message) ~= 'string' then
    error('SystemMessageEvent requires a message', 3)
  end

  if type(self.adventurer_name) ~= 'string' then
    error('SystemMessageEvent is missing the target adventurer_name', 3)
  end

  if self.indent and type(self.indent) ~= 'number' then
    error('SystemMessageEvent takes indent but only as a number', 3)
  end
end

function SystemMessageEvent:process(game_ctx, local_ctx)
  local loc_advn_name = adventurers.get_local_name(game_ctx, local_ctx)

  if not loc_advn_name then return end
  if loc_advn_name ~= self.adventurer_name then
    return
  end

  io.write('\27[2K\r')
  word_wrap.print_wrapped(self.message, self.indent or 0)
  local_ctx.dirty = true
end

prototype.support(SystemMessageEvent, 'event')
prototype.support(SystemMessageEvent, 'serializable')
return class.create('SystemMessageEvent', SystemMessageEvent)
