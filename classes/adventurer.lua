--- Describes an adventurer, which is someone played by a
-- person. Implements serializable
--
-- @classmod Adventurer

local class = require('classes/class')
local prototype = require('prototypes/prototype')

local array = require('functional/array')

require('prototypes/serializable')

local event_serializer = require('functional/event_serializer')

local Adventurer = {}

-- region serializable
function Adventurer:serialize()
  -- locations is an array of strings
  -- passives is an array of primitive tables where each table has a 'name' key
  -- active_ability is a table of { duration: number, ability: Event }
  -- detected_arr is a table of adventurer names
  -- detected_lookup is a table of adventurer names as keys to their indexes in detected_arr

  local serd_passives = self.passives and array.public_primitives_deep_copy(self.passives) or nil
  local serd_active_ability = nil
  if self.active_ability then
    serd_active_ability = {
      duration = self.active_ability.duration,
      ability = event_serializer.serialize(self.active_ability.ability)
    }
  end

  return {
    name = self.name,
    alive = self.alive,
    locations = array.public_primitives_deep_copy(self.locations),
    specialization = self.specialization,
    passives = serd_passives,
    active_ability = serd_active_ability,
    detected_arr = self.detected_arr,
    detected_lookup = self.detected_lookup
   }
end

function Adventurer.deserialize(serd)
  local unserd = {
    name = serd.name,
    alive = serd.alive,
    locations = serd.locations,
    specialization = serd.specialization,
    passives = serd.passives,
    detected_arr = serd.detected_arr,
    detected_lookup = serd.detected_lookup
  }

  if serd.active_ability then
    unserd.active_ability = {
      duration = serd.active_ability.duration,
      ability = event_serializer.deserialize(serd.active_ability.ability)
    }
  end

  return Adventurer._wrapped_class:new(unserd)
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

  if self.active_ability then
    if type(self.active_ability) ~= 'table' then
      error('Adventurers active ability should be a table!', 3)
    end

    if type(self.active_ability.duration) ~= 'number' then
      error('Adventurers active ability should have a \'duration\' key as a number!', 3)
    end

    if not class.is_class(self.active_ability.ability) then
      error('Adventurers active ability should be an Event to be raised on completion!', 3)
    end
  end

  if self.detected_arr ~= nil then
    if type(self.detected_arr) ~= 'table' then
      error('Adventurers detected_arr should be a table!', 3)
    end

    if type(self.detected_lookup) ~= 'table' then
      error('Adventurers with a detected_arr need a corresponding detected_lookup!', 3);
    end

    self:verify_detected()
  elseif self.detected_lookup ~= nil then
    error('Adventurers with a detected_lookup need a corresponding detected_arr!', 3);
  else
    self.detected_arr = {}
    self.detected_lookup = {}
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

--- Verify the integrity of the detected_arr vs detected_lookup arrays
-- Throws an error if there is a mismatch
function Adventurer:verify_detected()
  for advn_nm, ind in pairs(self.detected_lookup) do
    if self.detected_arr[ind] ~= advn_nm then
      error(string.format("Adventurers detected_arr/detected_lookup mismatch: detected_lookup['%s'] = %d but detected_arr[%d] = '%s' (type='%s')",
        advn_nm, ind, ind, tostring(self.detected_arr[ind]), type(self.detected_arr[ind])))
    end
  end

  for ind, advn_nm in ipairs(self.detected_arr) do
    if self.detected_lookup[advn_nm] ~= ind then
      error(string.format("Adventurers detected_arr/detected_lookup mismatch: detected_arr[%d] = '%s' but detected_lookup['%s'] = %s (type='%s')",
        ind, advn_nm, advn_nm, tostring(self.detected_lookup[advn_nm]), type(self.detected_lookup[advn_nm])))
    end
  end
end

--- Set no detected adventurers
function Adventurer:clear_detected()
  self.detected_arr = {}
  self.detected_lookup = {}
end

--- Ad the given adventurer as detected
-- @tparam advn_nm the name of the adventurer to add
function Adventurer:add_detected(advn_nm)
  if self.detected_lookup[advn_nm] then
    error(string.format('[Adventurer name=\'%s\'] - already have \'%s\' detected!', self.name, advn_nm), 2)
  end

  table.insert(self.detected_arr, advn_nm)
  self.detected_lookup[advn_nm] = #self.detected_arr
end

--- Determine if the given adventurer is detected by this adventurer
-- @tparam string advn_nm the name of the adventurer to check
-- @treturn boolean if the adventurer is detected by this adventurer
function Adventurer:is_detected(advn_nm)
  return self.detected_lookup[advn_nm] ~= nil
end

--- Remoe a specific adventurer from this adventurers detected adventurers
-- @tparam string advn_nm the adventurer to no longer have as detected 
function Adventurer:remove_detected(advn_nm)
  local ind = self.detected_lookup[advn_nm]
  if ind == nil then
    error(string.format('[Adventurer name=\'%s\'] can\'t remove \'%s\' from detected (he\'s already not detected!)', self.name, advn_nm), 2)
  end

  -- Manually shift-left in order to ensure integrity
  self.detected_lookup[advn_nm] = nil

  local orig_len = #self.detected_arr
  for move_left_ind = ind + 1, orig_len do
    local nm = self.detected_arr[move_left_ind]
    self.detected_arr[move_left_ind - 1] = nm
    self.detected_lookup[nm] = move_left_ind - 1
    self.detected_arr[move_left_ind] = nil
  end
end

prototype.support(Adventurer, 'serializable')
return class.create('Adventurer', Adventurer)
