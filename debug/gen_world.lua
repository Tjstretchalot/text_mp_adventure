-- This file can be edited for use in commands/run_file

local game_ctx, local_ctx = ...

local world = require('classes/world/world')

local w = world:new({
  graph = {
    location = 'open_market',
    nearby_locs = {},
    nearby_nodes = {}
  }
})

local function toms(minutes)
  return 1000 * 60 * minutes
end

w:add_location('church', {
  { location = 'open_market', time_ms = toms(15) }
})
w:add_location('courtyards', {
  { location = 'open_market', time_ms = toms(15) }
})
w:add_location('outskirts4', {
  { location = 'open_market', time_ms = toms(45) }
})
w:add_location('graveyard', {
  { location = 'outskirts4', time_ms = toms(15) }
})
w:add_location('outskirts3', {
  { location = 'outskirts4', time_ms = toms(30) },
  { location = 'open_market', time_ms = toms(45) }
})
w:add_location('outskirts2', {
  { location = 'outskirts3', time_ms = toms(30) },
  { location = 'open_market', time_ms = toms(45) }
})
w:add_location('farmc', {
  { location = 'outskirts2', time_ms = toms(15) }
})
w:add_location('outskirts1', {
  { location = 'outskirts2', time_ms = toms(30) }
})
w:add_location('farmb', {
  { location = 'outskirts2', time_ms = toms(15) }
})
w:add_location('outskirts6', {
  { location = 'outskirts1', time_ms = toms(60) }
})
w:add_location('outskirts5', {
  { location = 'outskirts6', time_ms = toms(60) },
  { location = 'outskirts4', time_ms = toms(30) }
})
w:add_location('farma', {
  { location = 'outskirts5', time_ms = toms(15) }
})
w:add_location('castle', {
  { location = 'courtyards', time_ms = toms(5) }
})

w:save('data/world.json')
return 'success'
