--- Right trim a string
-- @tparam string the string to trim right-spaces off of
-- @treturn string the right-trimmed version of the string
return function(string)
  local last_index = #string
  while string:sub(last_index, last_index) == ' ' do
    last_index = last_index - 1
  end

  if last_index < #string then
    return string:sub(1, last_index)
  end
  return string
end
