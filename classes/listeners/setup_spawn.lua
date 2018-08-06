--- Sets up the spawn location when the game starts
-- @classmod SetupSpawnListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local Location = require('classes/location')
local locations = require('functional/game_context/locations')
-- endregion


local SetupSpawnListener = {}

function SetupSpawnListener:get_events() return { NewGameEvent = true } end
function SetupSpawnListener:is_prelistener() return false end
function SetupSpawnListener:is_postlistener() return true end
function SetupSpawnListener:compare(other, pre) return 0 end
function SetupSpawnListener:process(game_ctx, local_ctx, networking, event)
  locations.add_location(game_ctx, Location:new({
    name = 'pregame',
    description = 'A place to hang out while we wait for more people'
  }))
end

prototype.support(SetupSpawnListener, 'listener')
return class.create('SetupSpawnListener', SetupSpawnListener)
