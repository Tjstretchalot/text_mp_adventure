--- This counter notes the number of adventurers that are queued to be added
-- it is only used when you are the host

local LocalContext = require('classes/local_context')

LocalContext:add_serialize_hook('adventurer_reserved_counter')
LocalContext:add_deserialize_hook('adventurer_reserved_counter')
