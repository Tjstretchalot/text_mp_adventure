--- This is the networked variant of LocalDetectorEvent. It simply runs
-- detection.determine_and_network_search
-- @classmod DetectorEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')

local adventurers = require('functional/game_context/adventurers')
local detection = require('functional/detection')
-- endregion

local DetectorEvent = {}

simple_serializer.inject(DetectorEvent)

function DetectorEvent:init()
  if type(self.detector_advn_nm) ~= 'string' then
    error(string.format('expected detector_advn_nm is string but got %s (type=%s)',
      tostring(self.detector_advn_nm), type(self.detector_advn_nm)), 3)
  end

  if type(self.tags) ~= 'table' then
    error(string.format('expected tags is table but got %s (type=%s)',
     tostring(self.tags), type(self.tags)), 3)
  end

  for k,v in pairs(self.tags) do
    if type(k) ~= 'string' then
      error(string.format('expected tags keys are strings but tags[%s] = %s (type of key is %s)',
        tostring(k), tostring(v), type(k)), 3)
    end

    if v ~= true then
      error(string.format('expected tags values are true but tags[\'%s\'] = %s (type of value is %s)',
        k, tostring(v), type(v)), 3)
    end
  end
end

function DetectorEvent:process(game_ctx, local_ctx, networking)
  if local_ctx.id ~= 0 then return end

  detection.determine_and_network_search(game_ctx, local_ctx, networking,
    self.detector_advn_nm, self.tags)
end

prototype.support(DetectorEvent, 'event')
prototype.support(DetectorEvent, 'serializable')
return class.create('DetectorEvent', DetectorEvent)
