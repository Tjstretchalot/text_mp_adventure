--- The ability listener manager
-- Abilities go through many phases before they actually occur. Trying
-- to listen for everything directly is both confusing and slow, because
-- instead of a dictionary lookup as in the base listener processor, ability
-- phases all have the same class names so you need to check the wrapped
-- event classname.
--
-- Thus, the ability listener manager is built on top of the listener
-- processor by actually being its *own* listener. It then delegates to
-- its corresponding listeners using its own dictionary lookup for listeners
-- to event class names, but instead specifically for the *wrapped* ability
-- event.
--
-- Ability listeners have callbacks for:
--   - Determining if a local ability can be started (LocaLAbilityEvent pre)
--   - When an ability succeeds/fails at being started (LocalAbilityEvent post)
--   - Before/after the ability is added to the adventurer (AdventurerEvent type='ability' pre/post)
--   - Before/after the ability duration is decreased (AbilityProgressEvent pre/post)
--   - Before/after if/when the ability is cancelled (AbilityCancelledEvent pre/post)
--   - Determining if the ability succeeds (LocalAbilityFinishedEvent pre)
--   - When the ability succeeds/fails (LocalAbilityFinishedEvent post)
--   - Before/after the ability is processed (the actual callback event, pre/post)
--
-- In order to reduce the amount of clutter on listeners that don't need to
-- handle *all* of these situations, you can use functional/ability_listener_noops
-- to autocomplete missing callbacks with no-op functions.
--
-- Like the generic ListenerProcessor, it is highly likely that the *order* that
-- listeners are called in needs to be finely tuned. Thus, this also allows the
-- listener to specify before/after by class name for other listeners. Also,
-- similiarly, this is only checked once (when the lists are being generated)
--
-- @classmod AbilityListenerManager

-- region imports
local deque = require('classes/dequeue/deque')
local array = require('functional/array')

local prototype = require('prototypes/prototype')
local class = require('classes/class')

local adventurers = require('functional/game_context/adventurers')
-- endregion

-- region fetching listeners
local all_listeners = require('classes/listeners/abilities/all')
-- endregion

-- region determining events
--- The events that we need to listen to
local events = {
  LocalAbilityEvent = true,
  AdventurerEvent = true,
  AbilityProgressEvent = true,
  AbilityCancelledEvent = true,
  LocalAbilityFinishedEvent = true
}

for _, list in ipairs(all_listeners) do
  local abil = list:get_listen_ability()
  events[abil] = true
end
-- endregion

-- region sorting listeners
local function comp_lists(list1, list2)
  local comp12 = list1:compare_listener(list2.class_name)
  local comp21 = list2:compare_listener(list1.class_name)

  if comp12 == -comp21 then return comp12 end
  if comp12 == 0 then return -comp21 end
  if comp21 == 0 then return comp12 end

  error(string.format('Invalid listener comparisons; list1 = %s, list2 = %s; comp12 = %d, comp21 = %d', list1.class_name, list2.class_name, comp12, comp21))
end

local wrapped_listeners = {}

for _, list in ipairs(all_listeners) do
  table.insert(wrapped_listeners, { listener = list, pre = {}, post = {} })
end

for i = 1, #all_listeners do
  local list1 = all_listeners[i]
  for j = i + 1, #all_listeners do
    local list2 = all_listeners[j]
    local comp = comp_lists(list1, list2)
    if comp == -1 then
      -- list1 before list2
      table.insert(wrapped_listeners[i].post, j)
      table.insert(wrapped_listeners[j].pre, i)
    elseif comp == 1 then
      table.insert(wrapped_listeners[i].pre, j)
      table.insert(wrapped_listeners[j].post, i)
    end
  end
end

local no_pre_que = deque.new()
for i, wlist in ipairs(wrapped_listeners) do
  if #wlist.pre == 0 then
    no_pre_que:push_right(i)
  end
end

local sorted_listeners = {}
while not no_pre_que:is_empty() do
  local next_ind = no_pre_que:pop_left()
  local next = wrapped_listeners[next_ind]
  table.insert(sorted_listeners, next.listener)

  for _, ind in ipairs(next.post) do
    local wlist = wrapped_listeners[ind]
    local i_in_pre = array.index_of(wlist.pre, next_ind)
    if i_in_pre < 1 then error('failed to find pre!') end

    table.remove(wlist.pre, i_in_pre)
    if #wlist.pre == 0 then
      no_pre_que:push_right(i)
    end
  end
end

if #sorted_listeners ~= #all_listeners then
  error('Failed to sort all ability listeners!')
end

wrapped_listeners = nil
no_pre_que = nil
all_listeners = nil
-- endregion

-- region listeners by event
-- this needs to be done after sorting to ensure we maintain sort
local listeners_by_event = {}
local client_listeners_by_event = {}

for _, list in ipairs(sorted_listeners) do
  local evnt = list:get_listen_ability()

  local lists_for_evnt = listeners_by_event[evnt]
  if lists_for_evnt == nil then
    lists_for_evnt = {}
    listeners_by_event[evnt] = lists_for_evnt
  end

  table.insert(lists_for_evnt, list)

  if list:listen_on_clients() then
    lists_for_evnt = client_listeners_by_event[evnt]
    if lists_for_evnt == nil then
      lists_for_evnt = {}
      client_listeners_by_event[evnt] = lists_for_evnt
    end
    table.insert(lists_for_evnt, list)
  end
end
-- endregion

local AbilityListenerManager = {}

function AbilityListenerManager:get_events() return events end
function AbilityListenerManager:is_prelistener() return true end
function AbilityListenerManager:is_postlistener() return true end
function AbilityListenerManager:compare(other, pre) return 0 end
function AbilityListenerManager:process_local_ability_event(game_ctx, local_ctx, networking, event, pre)
  local wrapped_event = event.callback_event
  local lists = listeners_by_event[wrapped_event.event_name]
  if not lists then return end

  if pre then
    for _, list in ipairs(lists) do
      if not event.result then break end

      local succ = list:can_start_ability(game_ctx, local_ctx, wrapped_event)
      if not succ then
        event.result = false
        break
      end
    end
  else
    for _, list in ipairs(lists) do
      list:on_ability_start_determined(game_ctx, local_ctx, wrapped_event, event.result)
    end
  end
end
function AbilityListenerManager:process_adventurer_event(game_ctx, local_ctx, networking, event, pre)
  if event.type ~= 'ability' then return end
  local lists_by_evnt = (local_ctx.id == 0 and listeners_by_event or client_listeners_by_event)

  local wrapped_event_cname = event.ability.ability.es_class_name
  local lists = lists_by_evnt[wrapped_event_cname]
  if not lists then return end

  if pre then
    for _, list in ipairs(lists) do
      list:pre_ability_started(game_ctx, local_ctx, networking, event)
    end
  else
    for _, list in ipairs(lists) do
      list:post_ability_started(game_ctx, local_ctx, networking, event)
    end
  end
end
function AbilityListenerManager:process_ability_progress_event(game_ctx, local_ctx, networking, event, pre)
  local wrapped_event
  local advn = adventurers.get_by_name(game_ctx, event.adventurer_name)
  if pre or advn.active_ability then
    wrapped_event = advn.active_ability.ability
  else
    wrapped_event = event.ability
  end

  local lists_by_evnt = (local_ctx.id == 0 and listeners_by_event or client_listeners_by_event)
  local lists = lists_by_evnt[wrapped_event.class_name]
  if not lists then return end

  for _, list in ipairs(lists) do
    list:ability_progress(game_ctx, local_ctx, networking, event, wrapped_event, pre)
  end
end
function AbilityListenerManager:process_ability_cancelled_event(game_ctx, local_ctx, networking, event, pre)
  local wrapped_event
  if pre then
    local advn = adventurers.get_by_name(game_ctx, event.adventurer_name)
    wrapped_event = advn.active_ability.ability
  else
    wrapped_event = event.ability
  end

  local lists_by_evnt = (local_ctx.id == 0 and listeners_by_event or client_listeners_by_event)
  local lists = lists_by_evnt[wrapped_event.class_name]
  if not lists then return end

  for _, list in ipairs(lists) do
    list:ability_cancelled(game_ctx, local_ctx, networking, event, wrapped_event, pre)
  end
end
function AbilityListenerManager:process_local_ability_finished_event(game_ctx, local_ctx, networking, event, pre)
  local wrapped_event = event.callback_event
  local lists = listeners_by_event[wrapped_event.class_name]
  if not lists then return end

  if pre then
    for _, list in ipairs(lists) do
      if not event.result then break end

      local succ = list:can_finish_ability(game_ctx, local_ctx, wrapped_event)
      if not succ then
        event.result = false
        break
      end
    end
  else
    for _, list in ipairs(lists) do
      list:on_ability_finish_determined(game_ctx, local_etx, wrapped_event, event.result)
    end
  end
end
function AbilityListenerManager:process_callback_event(game_ctx, local_ctx, networking, event, pre)
  local lists_by_evnt = (local_ctx.id == 0 and listeners_by_event or client_listeners_by_event)
  local lists = lists_by_evnt[event.class_name]
  if not lists then return end

  if pre then
    for _, list in ipairs(lists) do
      list:pre_ability(game_ctx, local_ctx, networking, event)
    end
  else
    for _, list in ipairs(lists) do
      list:post_ability(game_ctx, local_ctx, networking, event)
    end
  end
end

function AbilityListenerManager:process(game_ctx, local_ctx, networking, event, pre)
  if event.class_name == 'LocalAbilityEvent' then
    self:process_local_ability_event(game_ctx, local_ctx, networking, event, pre)
  elseif event.class_name == 'AdventurerEvent' then
    self:process_adventurer_event(game_ctx, local_ctx, networking, event, pre)
  elseif event.class_name == 'AbilityProgressEvent' then
    self:process_ability_progress_event(game_ctx, local_ctx, networking, event, pre)
  elseif event.class_name == 'AbilityCancelledEvent' then
    self:process_ability_cancelled_event(game_ctx, local_ctx, networking, event, pre)
  elseif event.class_name == 'LocalAbilityFinishedEvent' then
    self:process_local_ability_finished_event(game_ctx, local_ctx, networking, event, pre)
  else
    self:process_callback_event(game_ctx, local_ctx, networking, event, pre)
  end
end

prototype.support(AbilityListenerManager, 'listener')
return class.create('AbilityListenerManager', AbilityListenerManager)
