--- This module injects simple serialization
-- It uses public_primitives_deep_copy as the serializer
-- @module simple_serializer

local array = require('functional/array')

local simple_serializer = {}

-- region helpers
local function inject_serialize(self)
  return array.public_primitives_deep_copy(self)
end
local function inject_context_changed(self)
end
-- endregion

local inject

--- Inject the simple serialization methods into the given class,
-- including an empty context_changed function
--
-- @tparam table cls the class, before it has been created using class#create
function simple_serializer.inject(cls)
  cls.serialize = inject_serialize
  cls.context_changed = inject_context_changed

  cls.deserialize = function(serd)
    return cls._wrapped_class:new(serd)
  end
end

return simple_serializer
