--- Makes it a bit easier to serialize / unserialize arbitrary events
-- @module event_serializer

-- region imports
local all_events
-- endregion

local event_serializer = {}

--- Serialize the given event
-- @tparam Event evnt the event to serialize
-- @treturn table the serialized event
function event_serializer.serialize(evnt)
  -- the underscore makes it easier to note this isn't a real class
  return { _class_name = evnt.class_name, serialized = evnt:serialize() }
end

--- Deserialize the event serialized by serialize
-- @tparam table evnt the serialized event
-- @treturn Event the deserialized event
function event_serializer.deserialize(evnt)
  if not all_events then
    all_events = require('classes/events/all')
  end

  local cls = all_events[evnt._class_name]
  if not cls then
    print('[event_serializer] cannot deserialize: ')
    require('functional/inspect').inspect(evnt)
    error('No corresponding event found')
  end
  return cls.deserialize(evnt.serialized)
end

return event_serializer
