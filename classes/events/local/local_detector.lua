--- A detector event is an active effort by an adventurer to detect other
-- adventurers. The listeners must fill the eligible_to_detect table with
-- adventurers who the adventurer might be able to detect, along with
-- tags for why they may detect them.
--
-- Then, during the processing phase, this runs a LocalFailEvent for each of
-- the eligible detectables.  The identifier is 'LocalDetectorEvent' and the
-- source is:
--
-- {
--   adventurer_name: string (who is doing the detecting)
--   detectable_name: string (who might he be able to detect)
--   event_tags: {string,...} (tags for what the detector is doing)
--   detectable_tags: {string,...} (tags for why the detector can detect)
-- }
--
-- For each eligible detectable that does NOT fail, they are added to the
-- detected table. Then post-listeners must fire a networkable event to
-- distribute this information.
--
-- The detected table produced is just a list of adventurer names.
--
-- @classmod LocalDetectorEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
local adventurers = require('functional/game_context/adventurers')

local LocalFailEvent = require('classes/events/local/local_fail')
-- endregion

local LocalDetectorEvent = {}

simple_serializer.inject(LocalDetectorEvent)

function LocalDetectorEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error(string.format('LocalDetectorEvent expected adventurer_name is string, got %s (type=%s)', tostring(self.adventurer_name), type(self.adventurer_name)), 3)
  end

  if type(self.tags) ~= 'table' then
    error(string.format('LocalDetectorEvent requires tags (table of keys are the tag names and values are true), expected table, got %s (type=%s)', tostring(self.tags), type(self.tags)), 3)
  end

  for k,v in pairs(self.tags) do
    if type(k) ~= 'string' then
      error(string.format('LocalDetectorEvent weird key in tags; expected string, got %s (type=%s)', tostring(k), type(k)), 3)
    end

    if v ~= true then
      error(string.format('LocalDetectorEvent weird value in tags; expected true, got %s (type=%s)', tostring(v), type(v)), 3)
    end
  end

  if self.eligible_detectables ~= nil then
    error(string.format('LocalDetectorEvent weird eligible_detectables; expected nil, got %s (type=%s)', tostring(self.eligible_detectables), type(self.eligible_detectables)), 3)
  end

  self.eligible_detectables = {}

  if self.detected ~= nil then
    error(string.format('LocalDetectableEvent weird detected; expected nil, got %s (type=%s)', tostring(self.detected), type(self.detected)), 3)
  end
end

function LocalDetectorEvent:process(game_ctx, local_ctx, networking)
  self.detected = {}

  local detector, detector_ind = adventurers.get_by_name(game_ctx, self.adventurer_name)
  for _, detectable in ipairs(self.eligible_detectables) do
    local advn, advn_ind = adventurers.get_by_name(game_ctx, detectable.adventurer_name)

    if not detector:is_detected(detectable.adventurer_name) then
      local evnt = LocalFailEvent:new{
        adventurer_ind = advn_ind,
        identifier = 'LocalDetectorEvent',
        source = {
          adventurer_name = self.adventurer_name,
          detectable_name = detectable.adventurer_name,
          event_tags = self.tags,
          detectable_tags = detectable.tags
        }
      }

      local_ctx.listener_processor:invoke_pre_listeners(game_ctx, local_ctx, networking, evnt)
      evnt:process(game_ctx, local_ctx, networking)
      local_ctx.listener_processor:invoke_post_listeners(game_ctx, local_ctx, networking, evnt)

      if evnt.result then
        table.insert(self.detected, detectable.adventurer_name)
      end
    end
  end
end

--- Add the adventurer to the list of adventurers that can be detected by
-- the adventurer that is trying to detect.
--
-- This is preferable to adding them directly for the error checking and
-- deduplication
--
-- @tparam string advn_nm the adventurer that can be detected by self.adventurer_name
-- @tparam {string=boolean,...} the tags for the adventurer (must have at least one)
function LocalDetectorEvent:add_eligible_detectable(advn_nm, tags)
  if type(advn_nm) ~= 'string' then
    error(string.format('expected advn_nm is string, got %s (type=%s)', tostring(advn_nm), type(advn_nm)), 2)
  end

  if type(tags) ~= 'table' then
    error(string.format('exepcted tags is table, got %s (type=%s)', tostring(tags), type(tags)), 2)
  end

  for k,v in pairs(tags) do
    if type(k) ~= 'string' then
      error(string.format('expected keys in tags are strings, but tags[%s] = %s (type of key is %s)', tostring(k), tostring(v), type(k)), 2)
    end

    if v ~= true then
      error(string.format('expected values in tags are true, but tags[\'%s\'] = %s (type of value is %s)', k, tostring(v), type(v)), 2)
    end
  end

  -- first we try to find it and add the tags, otherwise we will insert it
  local found = false
  for _, elig in ipairs(self.eligible_detectables) do
    if elig.adventurer_name == advn_nm then
      found = elig
      break
    end
  end

  if not found then
    table.insert(self.eligible_detectables, { adventurer_name = advn_nm, tags = tags })
  else
    for tag, _ in pairs(tags) do
      found.tags[tag] = true
    end
  end
end

prototype.support(LocalDetectorEvent, 'event')
prototype.support(LocalDetectorEvent, 'serializable')
return class.create('LocalDetectorEvent', LocalDetectorEvent)
