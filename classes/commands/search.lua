--- This command searches the area via the SearchCommandEvent
-- @classmod SearchCommand

-- region imports
local class = require('classes/class')
local prototype = require('prototypes/prototype')

require('prototypes/command')

local arg_parser = require('functional/arg_parser')
local adventurers = require('functional/game_context/adventurers')

local SearchCommandEvent = require('classes/events/search_command')
-- endregion

local SearchCommand = {}

function SearchCommand:print_help()
  print('/search')
  print('  searches where you are located for other people')
end

function SearchCommand.priority() return 'explicit' end

function SearchCommand:parse(game_ctx, local_ctx, text)
  if game_ctx.in_setup_phase then return false, nil end

  if #text >= 7 and text:sub(1, 7) == '/search' then
    print('\r' .. text)

    local loc_nm = adventurers.get_local_name(game_ctx, local_ctx)
    if not loc_nm then
      print('Missing local adventurer')
      return true, {}
    end

    return true, { SearchCommandEvent:new{ adventurer_name = loc_nm } }
  end

  return false, nil
end

prototype.support(SearchCommand, 'command')
return class.create('SearchCommand', SearchCommand)
