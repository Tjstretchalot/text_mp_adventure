--- This class handles the listeners for processing events
-- @classmod ListenerProcessor

-- region imports
local class = require('classes/class')

local listeners = require('classes/listeners/all')
local events = require('classes/events/all')
-- endregion

local global_pre_listeners = {}
local global_post_listeners = {}
local listeners_by_event = {}
-- region parsing listeners by event
for _, list in ipairs(listeners) do
  local listens_to = list:get_events()
  local includes_pre = list:is_prelistener()
  local includes_post = list:is_postlistener()
  if listens_to == '*' then
    if includes_pre then
      global_pre_listeners[#global_pre_listeners + 1] = list
    end

    if includes_post then
      global_post_listeners[#global_post_listeners + 1] = list
    end
  else
    for _, evn in pairs(events) do
      if listens_to[evn.class_name] then
        local arr = listeners_by_event[evn.class_name]
        if not arr then
          arr = { pre = {}, post = {} }
          listeners_by_event[evn.class_name] = arr
        end

        if includes_pre then
          arr.pre[#arr.pre + 1] = list
        end

        if includes_post then
          arr.post[#arr.post + 1] = list
        end
      end
    end
  end
end
-- endregion
-- region ordering listeners
local function table_remove_by_value(tabl, val)
  local index = 0
  for ind, v in ipairs(tabl) do
    if val == v then
      index = ind
      break
    end
  end
  if index ~= 0 then
    table.remove(tabl, index)
  end
end

local function get_order(list1, list2, pre)
  local order1 = list1:compare(list2.class_name, pre)
  local order2 = list2:compare(list1.class_name, pre)

  if order1 == 0 then return -order2 end
  if order2 ~= 0 and order2 ~= -order1 then
    error('Bad order! list1.class_name = ' .. list1.class_name ..
      ', list2.class_name = ' .. list2.class_name .. ', pre = ' ..
      tostring(pre) .. ', list1:compare(list2) = ' .. tostring(order1) ..
      ', list2:compare(list1) = ' .. tostring(order2))
  end
  return order1
end

local function get_sorted_listeners(lists, pre)
  local nodes = {
    -- { before = {indexes}, after = {indexes} }
  }

  local len_lists = #lists
  for i=1, len_lists do
    nodes[i] = { before = {}, after = {} }
  end


  for i=1, len_lists do
    for j=i+1, len_lists do
      local order = get_order(lists[i], lists[j], pre)
      if order == -1 then
        table.insert(nodes[i].after, j)
        table.insert(nodes[j].before, i)
      elseif order == 1 then
        table.insert(nodes[i].before, j)
        table.insert(nodes[j].after, i)
      end
    end
  end


  local without_incoming = {}
  for i=1, len_lists do
    if #nodes[i].before == 0 then
      table.insert(without_incoming, i)
    end
  end

  local sorted = {}
  -- Kahn's algorithm

  while #without_incoming > 0 do
    local index = without_incoming[#without_incoming]
    without_incoming[#without_incoming] = nil

    local node = nodes[index]
    table.insert(sorted, lists[index])
    for _, after_ind in ipairs(node.after) do
      local after_node = nodes[after_ind]
      table_remove_by_value(after_node.before, index)
      if #after_node.before == 0 then
        table.insert(without_incoming, after_ind)
      end
    end
  end

  -- verify success
  for i, node in ipairs(nodes) do
    if #node.before > 0 then
      local msg = 'Detected cycle in listeners! Involved listeners: ' .. lists[i].class_name
      for j = 1, #node.before do
        msg = msg .. ', ' .. lists[node.before[j]].class_name
      end
      error(msg)
    end
  end

  return sorted
end

global_pre_listeners = get_sorted_listeners(global_pre_listeners, true)
global_post_listeners = get_sorted_listeners(global_post_listeners, false)
local new_listeners_by_event = {}
for evn_name, lists in pairs(listeners_by_event) do
  new_listeners_by_event[evn_name] = {
    pre = get_sorted_listeners(lists.pre, true),
    post = get_sorted_listeners(lists.post, true)
  }
end
listeners_by_event = new_listeners_by_event
-- endregion

local ListenerProcessor = {}

--- Invokes all prelisteners for the given event
-- This should be called immediately prior to processing the given event
-- @tparam GameContext game_ctx the game context
-- @tparam LocalContext local_ctx the local context
-- @tparam Networking networking the networking
-- @tparam Event event the event that is about to be processed
function ListenerProcessor:invoke_pre_listeners(game_ctx, local_ctx, networking, event)
  local lists = listeners_by_event[event.class_name]

  if lists then
    for _, list in ipairs(lists.pre) do
      list:process(game_ctx, local_ctx, networking, event, true)
    end
  end

  for _, list in ipairs(global_pre_listeners) do
    list:process(game_ctx, local_ctx, networking, event, true)
  end
end

--- Invokes all postlisteners for the given event
-- This should be called immediately after processing the event
-- @tparam GameContext game_ctx the game context
-- @tparam LocalContext local_ctx the local context
-- @tparam Networking networking the networking
-- @tparam Event event the event that was just processed
function ListenerProcessor:invoke_post_listeners(game_ctx, local_ctx, networking, event)
  local lists = listeners_by_event[event.class_name]

  if lists then
    for _, list in ipairs(lists.post) do
      list:process(game_ctx, local_ctx, networking, event, false)
    end
  end

  for _, list in ipairs(global_post_listeners) do
    list:process(game_ctx, local_ctx, networking, event, false)
  end
end

return class.create('ListenerProcessor', ListenerProcessor)
