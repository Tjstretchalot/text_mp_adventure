
local game_ctx, local_ctx = ...

local world = require('classes/world/world')
local w = world:new({
  graph = {
    location = 'one',
    nearby_locs = {},
    nearby_nodes = {}
  }
})

w:add_location('two', {
  { location = 'one', time_ms = 1 }
})

w:add_location('three', {
  { location = 'one', time_ms = 1 }
})

local w2 = world.deserialize(w:serialize())

return { w, w2 }
