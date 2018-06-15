--- Loads all the serializers

local file = require('functional/file')

local files = file.scandir('classes/game_context/serializers', true, false)
for _, file in ipairs(files) do
  if file ~= 'all.lua' and file:sub(-4) == '.lua' then
    require('classes/game_context/serializers/' .. file:sub(1, -5))
  end
end

return result
