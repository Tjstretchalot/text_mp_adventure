--- A detectable event is triggered when an adventurer does something
-- that other adventurers can detect. The listeners must fill the
-- eligible_detectors table by using add_eligible_detector. The listeners
-- must provide at leatt one tag for why the detector is allowed to detect.
--
-- Then, during the processing phase, this runs a LocalFailEvent for each
-- of the eligible detectors. The identifier is 'LocalDetectableEvent' and
-- the source is:
-- {
--   adventurer_name: string (who is doing the detectable thing),
--   detector_name: string (who is doing the detecting)
--   event_tags: {string,...} (tags for what they are doing)
--   detect_tags: {string,...} (tags for why the detector can detect)
-- }
--
-- For each eligible detector which does NOT fail, they are added to the
-- detectors table. The post-listeners must then fire a networkable event
-- to distribute this information to all the clients.
--
-- The detectors table produced is just a table of adventurer names.
--
-- @classmod LocalDetectableEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')
local adventurers = require('functional/game_context/adventurers')

local LocalFailEvent = require('classes/events/local/local_fail')
-- endregion

local LocalDetectableEvent = {}

simple_serializer.inject(LocalDetectableEvent)

function LocalDetectableEvent:init()
  if type(self.adventurer_name) ~= 'string' then
    error(string.format('LocalDetectableEvent expected adventurer_name is string, got %s (type=%s)', tostring(self.adventurer_name), type(self.adventurer_name)), 3)
  end

  if type(self.tags) ~= 'table' then
    error(string.format('LocalDetectableEvent requires tags (table of keys are the tag names and values are true), expected table, got %s (type=%s)', tostring(self.tags), type(self.tags)), 3)
  end

  for k,v in pairs(self.tags) do
    if type(k) ~= 'string' then
      error(string.format('LocalDetectableEvent weird key in tags; expected string, got %s (type=%s)', tostring(k), type(k)), 3)
    end

    if v ~= true then
      error(string.format('LocalDetectableEvent weird value in tags; expected true, got %s (type=%s)', tostring(v), type(v)), 3)
    end
  end

  if self.eligible_detectors ~= nil then
    error(string.format('LocalDetectableEvent weird eligible_detectors; expected nil, got %s (type=%s)', tostring(self.eligible_detectors), type(self.eligible_detectors)), 3)
  end

  self.eligible_detectors = {}

  if self.detectors ~= nil then
    error(string.format('LocalDetectableEvent weird detectors; expected nil, got %s (type=%s)', tostring(self.detectors), type(self.detectors)), 3)
  end
end

function LocalDetectableEvent:process(game_ctx, local_ctx, networking)
  self.detectors = {}

  for _, detector in ipairs(self.eligible_detectors) do
    local advn, advn_ind = adventurers.get_by_name(game_ctx, detector.adventurer_name)

    if not advn:is_detected(self.adventurer_name) then
      local evnt = LocalFailEvent:new{
        adventurer_ind = advn_ind,
        identifier = 'LocalDetectableEvent',
        source = {
          adventurer_name = self.adventurer_name,
          detector_name = advn.name,
          event_tags = self.tags,
          detect_tags = detector.tags
        }
      }

      local_ctx.listener_processor:invoke_pre_listeners(game_ctx, local_ctx, networking, evnt)
      evnt:process(game_ctx, local_ctx, networking)
      local_ctx.listener_processor:invoke_post_listeners(game_ctx, local_ctx, networking, evnt)

      if evnt.result then
        table.insert(self.detectors, advn.name)
      end
    end
  end
end

--- Add the adventurer to the list of adventurers that detected the adventurer
-- that did something detectable.
--
-- This is preferable to adding them directly for the error checking and
-- deduplication
--
-- @tparam string advn_nm the adventurer that detected self.adventurer_name
-- @tparam {string=boolean,...} the tags for the adventurer (must have at least one)
function LocalDetectableEvent:add_eligible_detector(advn_nm, tags)
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
  for _, elig in ipairs(self.eligible_detectors) do
    if elig.adventurer_name == advn_nm then
      found = elig
      break
    end
  end

  if not found then
    table.insert(self.eligible_detectors, { adventurer_name = advn_nm, tags = tags })
  else
    for tag, _ in pairs(tags) do
      found.tags[tag] = true
    end
  end
end

prototype.support(LocalDetectableEvent, 'event')
prototype.support(LocalDetectableEvent, 'serializable')
return class.create('LocalDetectableEvent', LocalDetectableEvent)
