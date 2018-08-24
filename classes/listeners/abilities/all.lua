--- Get all of the events as a dictionary
-- The keys are the class names, the values are the classes

local file = require('functional/file')

local result = {}

local dir = 'classes/listeners/abilities/'
local files = file.scandir(dir, true, false)
for _, file in ipairs(files) do
  if file:sub(-7) ~= 'all.lua' and file:sub(-4) == '.lua' then
    local tmp = require(dir .. file:sub(1, -5))
    table.insert(result, tmp)
  end
end

return result
