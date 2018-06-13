--- Marks the current output dirty

local LocalContext = require('classes/local_context')

LocalContext:add_serialize_hook('dirty')
LocalContext:add_deserialize_hook('dirty')
