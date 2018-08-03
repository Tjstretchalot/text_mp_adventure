--- Get all of the listeners as an array

local file = require('functional/file')

local result = {}
local function _scandir(dir)
  local files = file.scandir(dir, true, false)
  for _, file in ipairs(files) do
    if file:sub(-7) ~= 'all.lua' and file:sub(-4) == '.lua' then
      local tmp = require(dir .. file:sub(1, -5))
      result[#result + 1] = tmp
    end
  end

  local dirs = file.scandir(dir, false, true)
  for _, subdir in ipairs(dirs) do
    _scandir(dir .. subdir .. '/')
  end
end

_scandir('classes/listeners/')

return result
