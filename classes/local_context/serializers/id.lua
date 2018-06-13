--- This assigns an id to each local player

local LocalContext = require('classes/local_context')

LocalContext:add_serialize_hook('id')
LocalContext:add_deserialize_hook('id')
