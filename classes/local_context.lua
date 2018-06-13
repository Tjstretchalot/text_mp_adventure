--- This provides context for how the local player is interacting with the game
-- @classmod LocalContext

local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/serializable')

local hook_serializer = require('utils/hook_serializer')

local LocalContext = {}

hook_serializer.inject(LocalContext)

prototype.support(LocalContext, 'serializable')
return class.create('LocalContext', LocalContext)
