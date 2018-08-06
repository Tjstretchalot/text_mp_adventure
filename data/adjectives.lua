-- list of adjectives you could use to describe a person

local result = {
  ['ə'] = {
    'abandoned',
    'adorable',
    'accomplished',
    'adored',
    'afraid',
    'aggressive',
    'agreeable',
    'alarming',
    'amazing',
    'amused',
    'amusing',
    'another',
    'ashamed',
    'astonishing',
    'attentive',
    'attractive'
  },
  ['ā'] = {
    'able',
    'aged',
    'ancient'
  },
  ['ad'] = {
    'adventurous',
    'admirable',
    'admired'
  },
  ['ak'] = {
    'accurate',
    'acrobatic',
    'active'
  },
  ['ag'] = {
    'aggravating'
  },
  ['a'] =  {
    'agile',
    'agitated',
    'amazing',
    'anchored', -- technically aNG
    'angelic', -- techinically an
    'angry', -- techinically aNG
    'animated', -- anə
    'anxious', -- aNG
    'apprehensive',
    'athletic',
    'average'
  },
  ['är'] = {
    'artistic'
  },
  ['ô'] = {
    'awesome',
    'awful',
    'awkward'
  }
}

local keys = {}
for k, _ in pairs(result) do
  table.insert(keys, k)
end

return { keys, result }
