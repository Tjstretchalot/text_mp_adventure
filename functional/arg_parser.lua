--- Parses arguments
-- @module arg_parser

local arg_parser = {}

--- Returns the arguments as a table
-- @tparam string text the text to parse
-- @treturn {string,...} the arguments (not the actual command)
function arg_parser.parse(text)
  local first = true
  local res = {}
  for arg in text:gmatch('[^ ]+') do
    if first then
      first = false
    else
      res[#res + 1] = arg
    end
  end
  return res
end

return arg_parser
