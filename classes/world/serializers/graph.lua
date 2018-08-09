--- Serializes the graph by flattening it and suppresses serializing location_lookup
-- Note that the version of the graph in memory is very fast for doing the
-- operations we need but pretty terrible for serialization. So serialization
-- is an expensive process. Luckily, deserialization is very fast.
-- This version of serialization assumes SYMMETRIC CONNECTIONS
--[[
Converts
{
  location = 'Alpha',
  nearby_nodes = {
    {
      location = 'Beta',
      nearby_nodes = {
        Alpha -- circular reference that needs flattening
      },
      nearby_locs = {
        { location = 'Alpha', time_ms = 5000 } -- duplicated data that can be stripped
      }
    }
  },
  nearby_locs = {
    { location = 'Beta', time_ms = 5000 }
  }
}

to the flattened version
{
  {
    location = 'Alpha',
    nearby_unique = { { location = 'Beta', time_ms = 5000 } }
  },
  {
    location = 'Beta',
    nearby_unique = {}
  }
}

]]

local table = table

local deque = require('classes/dequeue/deque')
local World = require('classes/world/world')

local function copy_location_prims(loc)
  return { location = loc.location, time_ms = loc.time_ms }
end

World:add_serialize_hook('graph', function(self, copy, k, v)
  local flattened = {} -- final result
  local flat_locs = {} -- contains {location name = table in flattened}

  local que = deque.new()
  local current = { location = v.location, nearby_unique = {} }
  flat_locs[v.location] = current
  table.insert(flattened, current)
  que:push_right(current)

  while not que:is_empty() do
    current = que:pop_left()

    local unflat = self.location_lookup[current.location]
    for _, nearby_loc in ipairs(unflat.nearby_locs) do
      if not flat_locs[nearby_loc.location] then
        table.insert(current.nearby_unique, copy_location_prims(nearby_loc))

        local uniq = { location = nearby_loc.location, nearby_unique = {} }
        flat_locs[uniq.location] = uniq
        table.insert(flattened, uniq)

        que:push_right(uniq)
      end
    end
  end

  copy[k] = flattened
end)

World:add_deserialize_hook('graph', function(cls, serd, copy, k, serd_graph)
  local unflattened = nil -- final result
  local unflat_locs = {} -- acts like location_lookup

  -- first build the lookup skeleton
  for _, flat in ipairs(serd_graph) do
    local node = { location = flat.location, nearby_nodes = {}, nearby_locs = {} }
    unflat_locs[flat.location] = node

    if unflattened == nil then
      unflattened = node
    end
  end

  -- then just attach all the connections
  for _, flat in ipairs(serd_graph) do
    local loc = flat.location
    local node = unflat_locs[loc]

    for _, conn in ipairs(flat.nearby_unique) do
      local dest = unflat_locs[conn.location]

      table.insert(node.nearby_nodes, dest)
      table.insert(node.nearby_locs, copy_location_prims(conn))

      table.insert(dest.nearby_nodes, node)
      local inverted_conn = copy_location_prims(conn)
      inverted_conn.location = loc
      table.insert(dest.nearby_locs, inverted_conn)
    end
  end

  copy[k] = unflattened
  copy.location_lookup = unflat_locs
end)

World:add_serialize_hook('location_lookup', function() end)
