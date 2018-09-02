--- This class handles the listeners for processing events. This
-- class currently acts like a singleton but uses colon references
-- in case it needs to be upgraded to a true class.
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
    post = get_sorted_listeners(lists.post, false)
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

-- region add listener
local function add_listener_to_table_sorted(tbl, listener, pre)
  if #tbl == 0 then
    table.insert(tbl, listener)
    return
  end

  local earliest_index = 1
  local latest_index = #tbl + 1

  for i=1, #tbl do
    local listener_comp_to_tbli = get_order(listener, tbl[i], pre)

    if listener_comp_to_tbli < 0 then
      earliest_index = i + 1
    elseif listener_comp_to_tbli > 0 then
      latest_index = i
    end
  end

  if earliest_index < latest_index then
    local msg = 'Cannot add listener to table (pre=' .. tostring(pre) .. ')!\n'
    msg = msg .. string.format('  Listener: %s (pre=%s, post=%s)\n', listener.class_name, tostring(listener:is_prelistener()), tostring(listener:is_postlistener()))
    msg = msg .. 'Table:\n'
    for i=1, #tbl do
      local cls_nm = tbl[i].class_name
      local tbli_to_listener = tbl[i]:compare(listener.class_name, pre)
      local listener_to_tbli = listener:compare(tbl[i].class_name, pre)
      msg = msg .. string.format('  %s: to list: %d, to tbl[i]: %d\n', cls_nm, tbli_to_listener, listener_to_tbli)
    end
    msg = msg .. 'earliest_index: ' .. tostring(earliest_index)
    msg = msg .. 'latest_index: ' .. tostring(latest_index)
  end

  if latest_index == #tbl + 1 then
    table.insert(tbl, listener)
  else
    table.insert(tbl, latest_index, listener)
  end
end

--- Adds a listener to the listener processor. This is slower than
-- having the listener be in the listener table in the first place,
-- however it's better than resorting every time. It's not particularly
-- optimized right now.
--
-- This is the only way to get a listener to be instance-specific right now.
-- @tparam Listener listener the listener to add
function ListenerProcessor:add_listener(listener)
  local listens_to = listener:get_events()
  local is_pre = listener:is_prelistener()
  local is_post = listener:is_postlistener()

  if listens_to == '*' then
    if is_pre then
      add_listener_to_table_sorted(global_pre_listeners, listener, true)
    end
    if is_post then
      add_listener_to_table_sorted(global_post_listeners, listener, false)
    end
  else
    for evn_nm, _ in pairs(listens_to) do
      local lists = listeners_by_event[evn_nm]
      if not lists then
        lists = { pre = {}, post = {} }
        listeners_by_event[evn_nm] = lists
      end

      if is_pre then
        add_listener_to_table_sorted(lists.pre, listener, true)
      end
      if is_post then
        add_listener_to_table_sorted(lists.post, listener, false)
      end
    end
  end
end

--- Remove the specified listener by reference equality
-- @tparam listener the listener to remvoe
function ListenerProcessor:remove_listener(listener)
  local listens_to = listener:get_events()
  local is_pre = listener:is_prelistener()
  local is_post = listener:is_postlistener()

  if listens_to == '*' then
    if is_pre then
      table_remove_by_value(global_pre_listeners, listener)
    end
    if is_post then
      table_remove_by_value(global_post_listeners, listener)
    end
  else
    for _, evn_nm in ipairs(listens_to) do
      local lists = listeners_by_event[evn_nm]
      if is_pre then
        table_remove_by_value(lists.pre, listener)
      end
      if is_post then
        table_remove_by_value(lists.post, listener)
      end
    end
  end
end
-- endregion

return class.create('ListenerProcessor', ListenerProcessor)
