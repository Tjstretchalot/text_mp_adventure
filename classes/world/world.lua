--- This class contains the connection information about the world
-- The world is stored as a bidirected graph. Each element of
-- world is a table referred to as a WorldGraphNode that looks
-- like
--
-- ```
-- self.graph = {
--   location = string,
--   nearby_nodes = { WorldGraphNode, ... }
--   nearby_locs  = { {location = string, time_ms = number}, ...}
-- }
--```
--
-- In addition, there is a lookup table for location names -> world graph nodes
--
-- ```self.locations = { string = WorldGraphNode, ... }```
--
-- @classmod World

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/serializable')

local hook_serializer = require('utils/hook_serializer')
local deque = require('classes/dequeue/deque')
local json = require('json')
-- endregion

local World = {}

hook_serializer.inject(World)

--- Loads the world from the given file path and returns it
-- @tparam string file_path the path to load from
-- @treturn World the world in that path
function World.load(file_path)
  local file = io.open(file_path)
  local world = World._wrapped_class.deserialize(json.decode(file:read('*all')))
  file:close()

  return world
end

--- Convienence function for saving the world directly to file.
-- @tparam string file_path the path to save to
function World:save(file_path)
  local file = io.open(file_path, 'w')
  file:write(json.encode(self:serialize()))
  file:close()
end

function World:init()
  if not self.graph then error('Missing graph in world!', 3) end

  if not self.location_lookup then
    self:update_location_lookup()
  end
end

--- Update the location lookup from the graph
function World:update_location_lookup()
  local location_lookup = {}

  local stack = deque.new()
  stack:push_left(self.graph)

  location_lookup[self.graph.location] = self.graph

  while not stack:is_empty() do
    local popped = stack:pop_left()

    for _,n in ipairs(popped.nearby_nodes) do
      if not location_lookup[n.location] then
        location_lookup[n.location] = n
        stack:push_right(n)
      end
    end
  end

  self.location_lookup = location_lookup
end

--- Adds the new location to the map
-- @tparam string location the name of the location
-- @tparam {{location=string,time_ms=number},...} nearby
function World:add_location(location, nearby)
  local node = { location = location, nearby_locs = {}, nearby_nodes = {} }

  for _, loc in ipairs(nearby) do
    local nearby_n = self.location_lookup[loc.location]
    if not loc then
      error('Unknown nearby location ' .. tostring(loc.location), 2)
    end

    table.insert(node.nearby_locs, loc)
    table.insert(node.nearby_nodes, nearby_n)
  end

  -- we do this second so if we get an error in the above it doesn't pollute
  -- the graph

  for i=1, #nearby do
    local nearby_n = node.nearby_nodes[i]
    local nearby_l = node.nearby_locs[i]
    table.insert(nearby_n.nearby_nodes, node)
    table.insert(nearby_n.nearby_locs, { location = location, time_ms = nearby_l.time_ms })
  end

  self.location_lookup[location] = node
end

--- Adds a connection between the two locations
-- @tparam string loc1 the first location
-- @tparam string loc2 the second location
-- @tparam number time_ms the time to walk between the locations
function World:add_connection(loc1, loc2, time_ms)
  if not self.location_lookup[loc1] then
    error('Unknown loc1: ' .. tostring(loc1), 2)
  end

  if not self.location_lookup[loc2] then
    error('Unknown loc2: ' .. tostring(loc2))
  end

  local node1 = self.location_lookup[loc1]
  local node2 = self.location_lookup[loc2]

  table.insert(node1.nearby_locs, { location = loc2, time_ms = time_ms })
  table.insert(node1.nearby_nodes, node2)

  table.insert(node2.nearby_locs, { location = loc1, time_ms = time_ms })
  table.insert(node2.nearby_nodes, node1)
end

--- Fetches all the locations which are nearby the given location
-- @tparam string location the name of the location
-- @treturn {location=string,time_ms=number}
function World:get_nearby(location)
  local node = self.location_lookup[location]
  if not node then error('Unknown location: ' .. tostring(location), 2) end

  return node.nearby_locs
end

World._serialize_pre_callbacks = { function() require('classes/world/serializers/all') end }

prototype.support(World, 'serializable')
return class.create('World', World)
