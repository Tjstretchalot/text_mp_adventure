--- Get all of the bots by class name to class.

local file = require('functional/file')
local prototype = require('prototypes/prototype')

local result = {}
local function _scandir(dir)
  local files = file.scandir(dir, true, false)
  for _, file in ipairs(files) do
    if file:sub(-7) ~= 'all.lua' and file:sub(-4) == '.lua' then
      local tmp = require(dir .. file:sub(1, -5))
      if not prototype.is_supported_by(tmp, 'bot') then
        error('Class ' .. tmp.class_name .. ' does not support bot prototype!')
      elseif not prototype.is_supported_by(tmp, 'serializable') then
        error('Class ' .. tmp.class_name .. ' does not support serializable!')
      end

      result[tmp.class_name] = tmp
    end
  end

  local dirs = file.scandir(dir, false, true)
  for _, subdir in ipairs(dirs) do
    _scandir(dir .. subdir .. '/')
  end
end

_scandir('classes/bots/')

return result
