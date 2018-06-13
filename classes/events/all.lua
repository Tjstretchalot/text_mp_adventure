--- Get all of the events as a dictionary
-- The keys are the class names, the values are the classes

local file = require('functional/file')

local result = {}

local files = file.scandir('classes/events', true, false)
for _, file in ipairs(files) do
  if file ~= 'all.lua' and file:sub(-4) == '.lua' then
    local tmp = require('classes/events/' .. file:sub(1, -5))
    result[tmp.class_name] = tmp
  end
end

return result
