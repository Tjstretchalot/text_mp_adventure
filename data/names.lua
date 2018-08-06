-- These are names matched to what symbols sound good with them

local result = {
  ['ā'] = {
    'Ava',
    'Anna',
    'April',
    'Aiden'
  },
  ['ad'] = {
    'Abigail',
    'Adam',
    'Abraham'
  },
  ['a'] = {
    'Abigail',
    'Anna',
    'Amber',
    'Allison',
    'Alexandra',
    'Alex',
    'Amy',
    'Audrey',
    'Alice',
    'Arianna',
    'Ana',
    'Angela',
    'Annabelle',
    'Ali',
    'Anthony',
    'Andrew',
    'Adrian',
    'Asher',
    'Abram',
    'Anderson'
  },
  ['ə'] = {
    'Amanda',
    'Alexis',
    'Alexa',
    'Alexander',
    'Alyssa',
    'Andrea',
    'Amelia',
    'Adele',
    'Alicia',
    'Azalea'
  },
  ['är'] = {
    'Arther'
  },
  ['ô'] = {
    'Austin',
  }
}

local keys = {}
for k, _ in pairs(result) do
  table.insert(keys, k)
end

return { keys, result }
