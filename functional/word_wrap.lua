--- Adds word wrapped printing
-- @module word_wrap

local right_trim = require('functional/right_trim')

local word_wrap = {}

word_wrap.STYLES = {
  character = 'character', -- just do simply breaking by character
  word = 'word' -- attempt to break on words first
}

word_wrap.min_line_length = 25 -- used in word wrapping

word_wrap.console_width = 60
word_wrap.style = word_wrap.STYLES.word

--- Loads the console size using the 'mode' command for windows
function word_wrap.reload_console_width()
  local handle = io.popen('mode')
  local mode_info = handle:read('*all')
  handle:close()

  for line in mode_info:gmatch('[^\r\n]+') do
    line = line:gsub('%s+', '')
    if #line > 8 and line:sub(1, 8) == 'Columns:' then
      word_wrap.console_width = tonumber(line:sub(9))
      return
    end
  end

  print('Warning! Failed to find console width in word_wrap')
end

--- Performs character wrapping on the line
-- @tparam string line the line (must not contain newlines)
-- @tparam string indent the indent string
-- @tparam number length the length to wrap to
-- @treturn string the new line including injected indent and newlines
function word_wrap.wrap_character(line, indent, length)
  local trim_len = length - #indent
  local result = ''

  if #line <= trim_len then return line end

  local cur_index = 1
  while #line - cur_index >= trim_len do
    if cur_index ~= 1 then
      result = result .. '\n'
    end

    result = indent .. line:sub(cur_index, cur_index + trim_len - 1)
    cur_index = cur_index + trim_len
  end

  if cur_index < #line then
    if cur_index ~= 1 then
      result = result .. '\n'
    end
    result = indent .. line:sub(cur_index)
  end

  return result
end

--- Wraps the line breaking on a space if possible
-- @tparam string line the line (must not contain newlines)
-- @tparam string indent the indent string
-- @tparam number length the length to wrap to
-- @treturn string the new line including injected indent and newlines
function word_wrap.wrap_word(line, indent, length)
  local min_line_length = word_wrap.min_line_length
  local trim_len = length - #indent

  if #line <= trim_len then return indent .. line end

  local last_space = trim_len

  while line:sub(last_space, last_space) ~= ' ' and last_space > min_line_length do
    last_space = last_space - 1
  end

  if last_space == 0 then
    last_space = trim_len -- character wrapping
  end

  return indent .. line:sub(1, last_space) .. '\n' .. word_wrap.wrap_word(line:sub(last_space + 1), indent, length)
end

--- Attempts to wrap the given text to the given length
-- breaking according to the style
-- @tparam string line the line (must not contain newlines)
-- @tparam string indent the indent string
-- @tparam number length the length to wrap to
-- @treturn string the new line including injected indent and newlines
function word_wrap.wrap(line, indent, length)
  if word_wrap.style == word_wrap.STYLES.word then return word_wrap.wrap_word(line, indent, length)
  elseif word_wrap.style == word_wrap.STYLES.character then return word_wrap.wrap_character(line, indent, length) end

  error('Unknown word wrap style: ' .. tostring(word_wrap.style))
end

--- Prints the text wrapped, optionally with a given indent. Respects
-- forced newlines.
-- @tparam string text the text to print
-- @tparam number indent the number of spaces to prefix each line with, default 0
function word_wrap.print_wrapped(text, indent)
  indent = indent or 0

  local str_indent = ''
  for i = 1, indent do
    str_indent = str_indent .. ' '
  end

  for line in text:gmatch('[^\r\n]+') do
    line = right_trim(line)
    if #line > word_wrap.console_width - indent then
      print(word_wrap.wrap(line, str_indent, word_wrap.console_width))
    else
      print(str_indent .. line)
    end
  end
end

word_wrap.reload_console_width()
return word_wrap
