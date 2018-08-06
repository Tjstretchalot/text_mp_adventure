-- These are names matched to what symbols sound good with them

local result = {
  ['ā'] = {
    'Ava',
    'Anna',
    'April',
    'Aiden',
    'Amy'
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
    'Audrey',
    'Amanda',
    'Alexis',
    'Alexa',
    'Alexander',
    'Alyssa',
    'Andrea',
    'Amelia',
    'Adele',
    'Alicia',
    'Azalea',
    'Emilia',
    'Electra',
    'Eleisha',
    'Elisha',
    'Elizabeth',
    'Ellena',
    'Emilie'
  },
  ['är'] = {
    'Arther'
  },
  ['ô'] = {
    'Austin',
  },
  ['ē'] = {
    'Evie'
  },
  ['e'] = {
    'Ellie',
    'Elliot',
    'Emma',
    'Evan',
    'Evelyn',
    'Elsa',
    'Emmie',
    'Eddie',
    'Edgar',
    'Edin',
    'Edmund',
    'Elijah',
    'Ellenor',
    'Elvis',
    'Elloise',
    'Emer',
    'Emi',
    'Enrico'
  },
  ['i'] = {
    'Isabel',
    'Isabella',
    'Imani',
    'Indigo',
    'Indiana',
    'Izzy'
  }
}

local keys = {}
for k, _ in pairs(result) do
  table.insert(keys, k)
end

return { keys, result }
