--- This is called when we want to *add* a bot that *does not* yet have
-- an adventurer. This will push bot init onto the queue after pushing
-- a new adventurer to the queue.
--
-- The most important part of using an event for this is ensuring we don't
-- get duplicate adventurer names. Thus, if adding many bots at once they
-- must be wrapped to ensure they know the names of the previous bots
-- when deciding their name.
--
-- @classmod BotAddEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local adventurers = require('functional/game_context/adventurers')
local bots = require('classes/bots/all')
local random_names = require('functional/random_names')
local simple_serializer = require('utils/simple_serializer')
local spec_pool = require('classes/specializations/specialization_pool')

local AdventurerEvent = require('classes/events/adventurer')
local BotInitEvent = require('classes/events/bot_init')
-- endregion

local BotAddEvent = {}

simple_serializer.inject(BotAddEvent)

function BotAddEvent:init()
  if type(self.specialization) ~= 'string' then
    error('missing specialization', 3)
  end

  if not spec_pool.specs_by_name[self.specialization] then
    error(string.format('unknown specialization: \'%s\'', self.specialization), 3)
  end

  if type(self.bot_class_name) ~= 'string' then
    error('missing bot class name', 3)
  end

  if not bots[self.bot_class_name] then
    error(string.format('unknown bot class: \'%s\'', self.bot_class_name), 3)
  end
end

function BotAddEvent:process(game_ctx, local_ctx, networking)
  if local_ctx.id ~= 0 then return end

  local name = random_names:generate()
  local advn, advn_ind = adventurers.get_by_name(name)
  local tries = 1
  while advn do
    if tries > 10 then error('took too many tries to select a name') end

    name = random_names:generate()
    advn, advn_ind = adventurers.get_by_name(name)
    tries = tries + 1
  end

  local spec = spec_pool:get_by_name(self.specialization)
  local loc = spec:get_random_starting_location(game_ctx, local_ctx)

  local events = {
    AdventurerEvent:new{type = 'add', name = name},
    AdventurerEvent:new{type = 'move', adventurer_name = name, location_name = loc},
    AdventurerEvent:new{type = 'spec', adventurer_name = name, specialization = self.specialization},
    BotInitEvent:new{bot_class_name = self.bot_class_name, adventurer_name = name}
  }
  networking:broadcast_events(game_ctx, local_ctx, events)
end

prototype.support(BotAddEvent, 'event')
prototype.support(BotAddEvent, 'serializable')
return class.create('BotAddEvent', BotAddEvent)
