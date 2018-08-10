--- Generates the location information (locations contain what is there
-- and how it functions, world contains how the locations are connected)

local Location = require('classes/location')
local locs = {}

-- region open market
table.insert(locs, Location:new{
  name = 'open_market',
  description = 'The center of town',
  consecrated = false,
  lighting = 'outside'
})
-- endregion
-- region church
table.insert(locs, Location:new{
  name = 'church',
  description = 'A place for worship and protection',
  consecrated = true,
  lighting = 'inside_electricity'
})
-- endregion
-- region courtyards
table.insert(locs, Location:new{
  name = 'courtyards',
  description = 'Outside the castle with a beautiful garden',
  consecrated = false,
  lighting = 'outside'
})
-- endregion
-- region castle
table.insert(locs, Location:new{
  name = 'castle',
  description = 'A giant fortified castle',
  consecrated = false,
  lighting = 'outside'
})
-- endregion
-- region graveyard
table.insert(locs, Location:new{
  name = 'graveyard',
  description = 'The graveyard at the outskirts of town',
  consecrated = false,
  lighting = 'outside'
})
-- endregion
-- region outskirts1
table.insert(locs, Location:new{
  name = 'outskirts1',
  description = 'The outskirts behind housing region 3',
  consecrated = false,
  lighting = 'outside'
})
-- endregion
-- region farmb
table.insert(locs, Location:new{
  name = 'farmb',
  description = 'An old farm in outskirts 1',
  consecrated = false,
  lighting = 'inside_electricity'
})
-- endregion
-- region outskirst2
table.insert(locs, Location:new{
  name = 'outskirts2',
  description = 'The outskirts behind the church',
  consecrated = false,
  lighting = 'outside'
})
-- endregion
-- region farmc
table.insert(locs, Location:new{
  name = 'farmc',
  description = 'The farm in outskirts 2',
  consecrated = false,
  lighting = 'inside_electricity'
})
-- endregion
-- region outskirst3
table.insert(locs, Location:new{
  name = 'outskirts3',
  description = 'The outskirts behind housing region 1',
  consecrated = false,
  lighting = 'outside'
})
-- endregion
-- region outskirst4
table.insert(locs, Location:new{
  name = 'outskirts4',
  description = 'The outskirts behind the crafting region',
  consecrated = false,
  lighting = 'outside'
})
-- endregion
-- region outskirst5
table.insert(locs, Location:new{
  name = 'outskirts5',
  description = 'The outskirts behind housing region 2',
  consecrated = false,
  lighting = 'outside'
})
-- endregion
-- region farma
table.insert(locs, Location:new{
  name = 'farma',
  description = 'The farm in outskirts 5',
  consecrated = false,
  lighting = 'inside_electricity'
})
-- endregion
-- region outskirst6
table.insert(locs, Location:new{
  name = 'outskirts6',
  description = 'The outskirts behind the castle walls',
  consecrated = false,
  lighting = 'outside'
})
-- endregion

-- region save
local serd = {}
for k, loc in ipairs(locs) do
  table.insert(serd, loc:serialize())
end
local file = io.open('data/locations.json', 'w')
file:write(json.encode(serd))
file:close()

return 'success'
-- endregion
