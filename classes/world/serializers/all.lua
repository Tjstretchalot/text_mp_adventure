--- Loads all of the serializers for the world

local file = require('functional/file')

local dir = 'classes/world/serializers/'
local files = file.scandir(dir, true, false)

for _, f in ipairs(files) do
  if f:sub(-7) ~= 'all.lua' and f:sub(-4) == '.lua' then
    require(dir .. f:sub(1, -5))
  end
end
