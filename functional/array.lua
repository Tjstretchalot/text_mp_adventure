--- Utility functions for operating on indexed-associative-tables
-- @module array

local array = {}

--- Get the index of val in arr or -1 if not found
-- @tparam table arr the array to search
-- @tparam ? val the value to search for
-- @treturn number the index of val in arr or -1
function array.index_of(arr, val)
  if not arr then return -1 end

  for i,v in ipairs(arr) do
    if v == val then return i end
  end
  return -1
end

--- Determine if the array contains the specified value
-- @tparam table arr the array to search
-- @tparam ? val the value to search for
-- @treturn boolean true if arr contains val, false otherwise
function array.contains(arr, val)
  return array.index_of(arr, val) ~= -1
end

--- Copy only the non-private primitives of the given array
--
-- Takes only the public variables from the given array, where
-- they are either primitives or tables contianing only primitives
-- and returns those as a deep copy. It does not skip non-primitives -
-- it throws an error.
--
-- Public variables are detected by checking that they do not start
-- with an underscore.
function array.public_primitives_deep_copy(arr)
  local copy = {}
  for k,v in pairs(arr) do
    if type(k) == 'number' or k:sub(1, 1) ~= '_' then
      local tp = type(v)
      if tp == 'table' then
        copy[k] = array.public_primitives_deep_copy(v)
      elseif tp == 'string' or tp == 'number' or tp == 'boolean' then
        copy[k] = v
      else
        error('arr[\'' .. tostring(k) .. '\'] is a ' .. tp .. ', not a primitive', 2)
      end
    end
  end
  return copy
end

return array
