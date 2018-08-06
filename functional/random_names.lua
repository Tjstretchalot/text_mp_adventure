--- Generates a random name and returns it
-- @module random_names

local math = math

local adj_keys, adjectives = unpack(require('data/adjectives'))
local names_keys, names = unpack(require('data/names'))

local phonetics = {}
for _, k in ipairs(adj_keys) do
  for __, k2 in ipairs(names_keys) do
    if k == k2 then
      table.insert(phonetics, k)
      break
    end
  end
end

local random_names = {}

function random_names:generate()
  local ind = math.random(#phonetics)
  local phon = phonetics[ind]

  ind = math.random(#names[phon])
  local name = names[phon][ind]

  ind = math.random(#adjectives[phon])
  local adj = adjectives[phon][ind]

  local first_let = adj:sub(1, 1)
  first_let = first_let:upper()
  adj = first_let .. adj:sub(2)
  return adj .. ' ' .. name
end

return random_names
