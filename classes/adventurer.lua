--- Describes an adventurer, which is someone played by a
-- person. Implements serializable
--
-- @classmod Adventurer

local class = require('classes/class')
local prototype = require('prototypes/prototype')

local array = require('functional/array')

require('prototypes/serializable')

local Adventurer = {}

-- region serializable
function Adventurer:serialize()
  -- locations is an array of strings
  -- passives is an array of primitive tables where each table has a 'name' key

  local serd_passives = passives and array.public_primitives_deep_copy(self.passives) or nil
  return {
    name = self.name,
    alive = self.alive,
    locations = array.public_primitives_deep_copy(self.locations),
    specialization = self.specialization,
    passives = serd_passives
   }
end

function Adventurer.deserialize(serd)
  return Adventurer._wrapped_class:new(serd)
end

function Adventurer:context_changed(game_ctx)
end
-- endregion

function Adventurer:init()
  if type(self.name) ~= 'string' then
    error('Adventurers require names!', 3)
  end

  if self.locations == nil then
    self.locations = {}
  end

  if self.alive == nil then
    self.alive = true
  end

  if type(self.specialization) ~= 'nil' and type(self.specialization) ~= 'string' then
    error('Weird specialization type ' .. type(self.specialization), 3)
  end

  if self.passives then
    if type(self.passives) ~= 'table' then
      error('Adventurers passives should be a table!', 3)
    end

    for k,passive in ipairs(self.passives) do
      if type(passive) ~= 'table' then
        error(string.format('type(passives[\'%s\']) = \'%s\' (table expected)', k, type(passive)), 3)
      end

      if type(passive.name) ~= 'string' then
        error(string.format('type(passives[\'%s\'].name) = \'%s\' (string expected)', k, type(passive.name)), 3)
      end
    end
  end
end

--- Determine if this adventurer has a passive by the given name
-- @tparam string name the name of the passive
-- @treturn boolean,{table,...}|nil if we have the passive, then all the passives with that name
function Adventurer:has_passive(name)
  if not self.passives then return false end

  local result = {}
  for k, passive in ipairs(self.passives) do
    if passive.name == name then
      table.insert(result, passive)
    end
  end

  if #result == 0 then return false, nil end
  return true, result
end

--- Add a passive with the given name or a table
-- @tparam table|string the passive (or name of passive) to add
function Adventurer:add_passive(passive)
  if type(passive) == 'string' then
    passive = { name = passive }
  else
    if type(passive) ~= 'table' then
      error('Expected passive is table or string, got ' .. type(passive), 2)
    end

    if type(passive.name) ~= 'string' then
      error('Expected passive.name is a string, got ' .. type(passive.name), 2)
    end
  end

  if self.passives == nil then
    self.passives = {}
  end

  table.insert(self.passives, passive)
end

--- Set the location of the adventurer to the new location,
-- replacing the old location if there is one.
-- @tparam string|{string,...} the location or locations to set it to
function Adventurer:replace_location(location)
  if not location then error('argument nil: location') end

  if type(location) == 'string' then
    self.locations = { location }
  else
    self.locations = {}
    for _,v in ipairs(location) do
      table.insert(self.locations, v)
    end
  end
end

prototype.support(Adventurer, 'serializable')
return class.create('Adventurer', Adventurer)
