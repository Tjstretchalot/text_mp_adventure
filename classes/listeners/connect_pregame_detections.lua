--- Pregame you should have everyone detected
-- @classmod ConnectPregameDetectionsListener

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/listener')

local adventurers = require('functional/game_context/adventurers')
local detection = require('functional/detection')
local system_messages = require('functional/system_messages')
-- endregion

local ConnectPregameDetectionsListener = {}

function ConnectPregameDetectionsListener:get_events() return { AdventurerEvent = true } end
function ConnectPregameDetectionsListener:is_prelistener() return false end
function ConnectPregameDetectionsListener:is_postlistener() return true end
function ConnectPregameDetectionsListener:compare(other, pre) return 0 end
function ConnectPregameDetectionsListener:process(game_ctx, local_ctx, networking, event)
  if local_ctx.id ~= 0 then return end
  if event.type ~= 'move' or event.location_name ~= 'pregame' then return end

  local advns = adventurers.get_by_location(game_ctx, 'pregame')
  for _, advn in ipairs(advns) do
    detection.determine_and_network_detection(game_ctx, local_ctx, networking, advn.name, { ConnectPregameDetectionsListener = true })
  end
end

prototype.support(ConnectPregameDetectionsListener, 'listener')
return class.create('ConnectPregameDetectionsListener', ConnectPregameDetectionsListener)
