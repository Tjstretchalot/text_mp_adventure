--- This is the networked variant of local_detectable. It simply runs
-- detection.determine_and_network_detection
-- @classmod DetectableEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local simple_serializer = require('utils/simple_serializer')

local adventurers = require('functional/game_context/adventurers')
local detection = require('functional/detection')
-- endregion

local DetectableEvent = {}

simple_serializer.inject(DetectableEvent)

function DetectableEvent:init()
  if type(self.detectable_advn_nm) ~= 'string' then
    error(string.format('expected detected_advn_nm is string but got %s (type=%s)',
      tostring(self.detectable_advn_nm), type(self.detectable_advn_nm)), 3)
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

function DetectableEvent:process(game_ctx, local_ctx, networking)
  if local_ctx.id ~= 0 then return end

  detection.determine_and_network_detection(game_ctx, local_ctx, networking,
    self.detectable_advn_nm, self.tags)
end

prototype.support(DetectableEvent, 'event')
prototype.support(DetectableEvent, 'serializable')
return class.create('DetectableEvent', DetectableEvent)
