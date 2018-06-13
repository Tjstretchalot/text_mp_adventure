--- Utility functions for working with files without lfs
-- @module file

local array = require('functional/array')

local file = {}

--- Scan the specified directory and return a list of files and/or directories
function file.scandir(dir, return_files, return_directories)
  if return_files == nil then return_files = true end
  if return_directories == nil then return_directories = true end

  if not return_files and not return_directories then return {} end

  local handle
  local result = {}
  local line

  if return_files and return_directories then
    handle = io.popen('dir "' .. dir .. '" /b')
    line = handle:read('*line')
    while line do
      result[#result + 1] = line
      line = handle:read('*line')
    end
    handle:close()
    return result
  end

  handle = io.popen('dir "' .. dir .. '" /b /ad')
  result = {}
  line = handle:read('*line')
  while line do
    result[#result + 1] = line
    line = handle:read('*line')
  end
  handle:close()

  if not return_files then return result end

  -- return files but not directories
  local directories = result
  result = {}

  handle = io.popen('dir "' .. dir .. '" /b')
  line = handle:read('*line')
  while line do
    if not array.contains(directories, line) then
      result[#result + 1] = line
    end
    line = handle:read('*line')
  end

  return result
end

return file
