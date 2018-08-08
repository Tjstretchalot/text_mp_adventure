--- Parses arguments
-- @module arg_parser

local arg_parser = {}

--- Returns the arguments as a table
-- Would parse something like /test hey how you doin' my 'man child'
-- into { 'hey', 'how', 'you', 'doin\'', 'my', '\'man', 'child\'' }
-- Good for simplistic commands, x
-- /adventurers --list
-- -> { '--list' }
-- @tparam string text the text to parse
-- @treturn {string,...},string the arguments (not the actual command) followed by the command
function arg_parser.parse(text)
  local first = true
  local command
  local res = {}
  for arg in text:gmatch('[^ ]+') do
    if first then
      first = false
      command = arg
    else
      res[#res + 1] = arg
    end
  end
  return res, command
end

local stringbyte = string.byte
local stringchar = string.char
local tableconcat = table.concat

--- Returns the arguments as a table
-- This handles phrases like /test 'some spaced' "alternative 'spaces'" m\'man
-- into -> { '/test', 'some spaced', 'alternative \'spaces\'', 'm\'man' }
-- @tparam string text the text to parse
-- @treturn boolean|{string,...} the arguments (INCLUDING the actual command), or false on error
-- @treturn ?|string the error message if the first result was 'false'
function arg_parser.parse_allow_quotes(text)
  local res = {}

  local space_character = stringbyte(' ')
  local single_quote_character = stringbyte('\'')
  local double_quote_character = stringbyte('"')
  local escape_character = stringbyte('\\')

  local escaped = false
  local expecting_space = false

  local curr = {}
  local saw_single_quote = false
  local saw_double_quote = false

  local text_tbld = {stringbyte(text, 1, #text)}
  for k = 1, #text_tbld do
    local curr_by = text_tbld[k]

    if expecting_space then
      if curr_by == space_character then
        expecting_space = false
      else
        return false, 'Expecting a space at index ' .. k .. ' but got \'' .. stringchar(curr_by) .. '\''
      end
    elseif escaped then
      curr[#curr + 1] = stringchar(curr_by)
      escaped = false
    elseif curr_by == escape_character then
      escaped = true
    elseif curr_by == single_quote_character then
      if saw_single_quote then
        saw_single_quote = false
        expecting_space = true
        res[#res + 1] = tableconcat(curr, '')
        curr = {}
      elseif saw_double_quote then
        curr[#curr + 1] = stringchar(curr_by)
      elseif #curr == 0 then
        saw_single_quote = true
      else
        return false, 'Single quote in the middle of an argument is not allowed (escape with \\ or surround with double quotes)'
      end
    elseif curr_by == double_quote_character then
      if saw_single_quote then
        curr[#curr + 1] = stringchar(curr_by)
      elseif saw_double_quote then
        saw_double_quote = false
        expecting_space = true
        res[#res + 1] = tableconcat(curr, '')
        curr = {}
      elseif #curr == 0 then
        saw_double_quote = true
      else
        return false, 'Double quote in the middle of an argument is not allowed (escape with \\ or surround with single quotes)'
      end
    elseif curr_by == space_character then
      if not saw_single_quote and not saw_double_quote then
        res[#res + 1] = tableconcat(curr, '')
        curr = {}
      else
        curr[#curr + 1] = stringchar(curr_by)
      end
    else
      curr[#curr + 1] = stringchar(curr_by)
    end
  end

  if saw_single_quote then
    return false, 'Unexpected end-of-line (expected \')'
  elseif saw_double_quote then
    return false, 'Unexpected end-of-line (expected ")'
  elseif escaped then
    return false, 'Unexpected end-of-line (ended on a \\)'
  end

  if #curr ~= 0 then
    res[#res + 1] = tableconcat(curr, '')
  end

  return res
end

return arg_parser
