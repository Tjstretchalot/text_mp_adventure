--- The local fail event accumulates the sources for failing something.
-- This is a fairly general event; it must be given who would fail from
-- this, an identifier for the type of thing we're calculating, and
-- a variable 'source'
--
-- @classmod LocalFailEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')

local fail_calculator = require('functional/fail_calculator')
-- endregion

local LocalFailEvent = {}

simple_serializer.inject(LocalFailEvent)

function LocalFailEvent:init()
  if type(self.adventurer_ind) ~= 'number' then
    error('LocalFailEvent is missing adventurer_ind (the index in adventurers for who will fail if result is false)', 3)
  end

  if type(self.identifier) ~= 'string' then
    error('LocalFailEvent is missing identifier (a string identifier for source)', 3)
  end

  if type(self.source) == 'nil' then
    error('LocalFailEvent is missing source (whatever caused this)', 3)
  end

  self.ordered_probabilities = {}

  -- we will set self.result and self.triggered in the process
end

--- Add the chance to fail to the probabilities. This is preferable
-- to adding directly for gettng an error quicker for bad values.
-- @tparam string typ either 'multiplicative' or 'additive'
-- @tparam number chance the chance to fail (negative is acceptable). -1 through 1
-- @tparam string iden the identifier for the source
function LocalFailEvent:add_fail_chance(typ, chance, iden)
  if typ ~= 'multiplicative' and typ ~= 'additive' then
    error('Bad type: ' .. tostring(typ), 2)
  end

  if type(chance) ~= 'number' then
    error('Bad chance: ' .. tostring(chance) .. ' (type=' .. type(chance) .. '; number expected)', 2)
  end

  if chance < -1 or chance > 1 then
    error('Bad chance: ' .. tostring(chance) .. ' (expected between (inc) -1 and 1)')
  end

  if type(iden) ~= 'string' then
    error('Bad iden: ' .. tostring(iden) .. ' (type=' .. type(iden) .. '; string expected)')
  end

  for _, p in ipairs(self.ordered_probabilities) do
    if p.iden == iden then
      error('Duplicate iden: ' .. iden)
    end
  end

  table.insert(self.ordered_probabilities, { type = typ, chance = chance, iden = iden })
end

function LocalFailEvent:process(game_ctx, local_ctx)
  local res, trig = fail_calculator.calculate(self.ordered_probabilities)
  self.result = res
  self.triggered = trig
end

--- Only functions after process
-- Determines if the given identifier was triggered
-- @tparam string iden the iden passed to add_fail_chance
-- @treturn boolean if it was triggered
function LocalFailEvent:was_triggered(iden)
  for _, ind in ipairs(self.triggered) do
    if self.ordered_probabilities[ind].iden == iden then return true end
  end
  return false
end

prototype.support(LocalFailEvent, 'event')
prototype.support(LocalFailEvent, 'serializable')
return class.create('LocalFailEvent', LocalFailEvent)
