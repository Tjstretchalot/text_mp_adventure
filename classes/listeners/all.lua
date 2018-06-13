--- Get all of the listeners as an array

local file = require('functional/file')

local result = {}

local files = file.scandir('classes/listeners', true, false)
for _, file in ipairs(files) do
  if file ~= 'all.lua' and file:sub(-4) == '.lua' then
    local tmp = require('classes/listeners/' .. file:sub(1, -5))
    result[#result + 1] = tmp
  end
end

return result
