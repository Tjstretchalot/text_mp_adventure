--- We don't save the listener processor

local LocalContext = require('classes/local_context')

LocalContext:add_serialize_hook('listener_processor', function(self, copy, k, v) end)
