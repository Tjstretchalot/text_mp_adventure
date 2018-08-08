--- A variant to the typical 'all' file that would be used
-- to fetch all specializations.
-- Expects one folder per specialization, with the name of the folder being
-- the lowercase name of the specialization and then one file with the name
-- name_spec. For example, folder name 'demogorgon', file name
-- 'demogorgon/demogorgon_spec
-- @module specialization_pool

local file = require('functional/file')

local specialization_pool = {}

--- Dictionary of {string,specialization}
specialization_pool.specs_by_name = {}

do
  local dirs = file.scandir('classes/specializations/', false, true)
  for _, dir in ipairs(dirs) do
    local spec = require('classes/specializations/' .. dir .. '/' .. dir .. '_spec')
    specialization_pool.specs_by_name[dir] = spec
  end
end

--- Get the specialization by that name or raise a
-- not found error.
-- @tparam string name the name of the specialization
-- @treturn specialization the specialization with that name
function specialization_pool:get_by_name(name)
  local spec = self.specs_by_name[name]
  if not spec then
    error('Specialization \'' .. name .. '\' not found.', 2)
  end

  return spec
end

return specialization_pool
