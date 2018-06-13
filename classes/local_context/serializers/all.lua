--- Loads all the local context serializers

local file = require('functional/file')

local result = {}

local files = file.scandir('classes/local_context/serializers', true, false)
for _, file in ipairs(files) do
  if file ~= 'all.lua' and file:sub(-4) == '.lua' then
    require('classes/local_context/serializers/' .. file:sub(1, -5))
  end
end
