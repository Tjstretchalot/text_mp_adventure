--- Describes the current state of the game.
-- @classmod GameContext

local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/serializable')

local hook_serializer = require('utils/hook_serializer')

local GameContext = {}

hook_serializer.inject(GameContext)

prototype.support(GameContext, 'serializable')
return class.create('GameContext', GameContext)
