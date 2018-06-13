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
      list:process(game_ctx, local_ctx, networking, event)
    end
  end

  for _, list in ipairs(global_pre_listeners) do
    list:process(game_ctx, local_ctx, networking, event)
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
      list:process(game_ctx, local_ctx, networking, event)
    end
  end

  for _, list in ipairs(global_post_listeners) do
    list:process(game_ctx, local_ctx, networking, event)
  end
end

return class.create('ListenerProcessor', ListenerProcessor)
