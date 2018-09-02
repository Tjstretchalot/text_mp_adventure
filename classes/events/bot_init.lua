--- Initializes a bot on the server, attached to a specific adventurer
-- @classmod BotInitEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local bots = require('classes/bots/all')
local simple_serializer = require('utils/simple_serializer')
-- endregion

local BotInitEvent = {}

simple_serializer.inject(BotInitEvent)

function BotInitEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error(string.format('missing adventurer_name (who to attach to); self.adventurer_name = %s, type = %s', tostring(self.adventurer_name), type(self.adventurer_name)), 3)
  end

  if type(self.bot_class_name) ~= 'string' then
    error(string.format('missing bot_class_name (the bot class); self.bot_class_name = %s, type = %s', tostring(self.bot_class_name), type(self.bot_class_name)), 3)
  end

  if not bots[self.bot_class_name] then
    error(string.format('unknown bot class: \'%s\'', self.bot_class_name), 3)
  end
end

function BotInitEvent:process(game_ctx, local_ctx)
  local bot_cls = bots[self.bot_class_name]
  local bot_inst = bot_cls:new{adventurer_name = self.adventurer_name}
  local_ctx.listener_processor:add_listener(bot_inst)
end

prototype.support(BotInitEvent, 'event')
prototype.support(BotInitEvent, 'serializable')
return class.create('BotInitEvent', BotInitEvent)
