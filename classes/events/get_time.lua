--- This handles the /time command. This works on unattached players as
-- well by skipping system messages.
-- @classmod GetTimeEvent

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/event')
require('prototypes/serializable')

local game_time = require('functional/game_time')
local system_messages = require('functional/system_messages')

local simple_serializer = require('utils/simple_serializer')
-- endregion

local GetTimeEvent = {}

simple_serializer.inject(GetTimeEvent)

function GetTimeEvent:init()
  if type(self.player_id) ~= 'number' then
    error('GetTimeEvent is missing player_id!', 3)
  end
end

function GetTimeEvent:process(game_ctx, local_ctx, networking)
  local text = '/time'
  local msg = game_time.pretty_12_hour_clock(game_ctx.day.game_ms_since_midnight)

  local advn_ind = game_ctx.adventurers_by_id[self.player_id]
  if advn_ind then
    if local_ctx.id == 0 then
      system_messages:send(game_ctx, local_ctx, networking, advn_ind, text, 0)
      system_messages:send(game_ctx, local_ctx, networking, advn_ind, msg, 0)
    end
  elseif local_ctx.id == self.player_id then
    print('\27[2K\r' .. text)
    print(msg)
    local_ctx.dirty = true
  end
end

prototype.support(GetTimeEvent, 'event')
prototype.support(GetTimeEvent, 'serializable')
return class.create('GetTimeEvent', GetTimeEvent)
