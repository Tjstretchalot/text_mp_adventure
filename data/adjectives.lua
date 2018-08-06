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
    'attractive',
    'elaborate',
    'elastic',
    'electric',
    'embarrassed',
    'emotional',
    'essential',
    'esteemed'
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
  },
  ['ē'] = {
    'eager',
    'easy',
    'evil'
  },
  ['ər'] = {
    'earnest',
    'early'
  },
  ['ek'] = {
    'ecstatic'
  },
  ['e'] = {
    'educated',
    'elderly',
    'elegant',
    'eminent',
    'empty',
    'energetic',
    'envious',
    'ethical',
    'excellent',
    'extroverted',
    'extra'
  },
  ['i'] = { -- in / ig / i
    'enchanted',
    'enchanting',
    'enlightened',
    'enormous',
    'enraged',
    'exalted',
    'exemplary',
    'exhausted',
    'excitable',
    'excited',
    'exciting',
    'exotic',
    'experienced',
    'immaculate',
    'icky',
    'idiotic',
    'ignorant',
    'ill-fated',
    'ill-informed',
    'illiterate',
    'illustrious',
    'imaginary',
    'imaginative',
    'immaculate',
    'immaterial',
    'impassioned',
    'impeccable',
    'impartial',
    'imperturbable',
    'impolite',
    'important',
    'impossible',
    'impractical',
    'impressionable',
    'impressive',
    'improbable',
    'impure',
    'incomparable',
    'incomplete',
    'inconsequential',
    'incredible',
    'inexperienced',
    'infamous',
    'infantile',
    'inferior',
    'informal',
    'innocent',
    'insecure',
    'insidious',
    'insignificant',
    'insistent',
    'instructive',
    'insubstantial',
    'intelligent',
    'interesting',
    'itchy'
  }
}

local keys = {}
for k, _ in pairs(result) do
  table.insert(keys, k)
end

return { keys, result }
