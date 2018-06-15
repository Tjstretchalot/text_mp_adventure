--- This module is used for inspecting things
-- It is specifically tuned for our object system.
-- It dumps using json
-- @module inspect

local json = require('json')
local array = require('functional/array')

local inspect = {}

function inspect.pretty_print_table(tabl, nest_level, indent_str, spotted)
  nest_level = nest_level or 0
  indent_str = indent_str or '  '
  spotted = spotted or { [tabl] = true }

  for k, v in pairs(tabl) do
    for i=1, nest_level do
      io.write(indent_str)
    end

    if type(k) == 'string' then io.write('\'') end
    io.write(k)
    if type(k) == 'string' then io.write('\'') end
    io.write(' = ')

    if type(v) == 'table' then
      if spotted[v] then
        io.write('{ .. omitted ' .. tostring(v) .. ' .. }\n')
      elseif k == '_class' then
        io.write('{ .. class ' .. v.class_name .. ' omitted .. }\n')
      else
        spotted[v] = true
        io.write(tostring(v) .. ' = {\n')
        inspect.pretty_print_table(v, nest_level + 1, indent_str, spotted)
        for i=1, nest_level do
          io.write(indent_str)
        end
        io.write('}\n')
      end
    elseif type(v) == 'string' then
      io.write('\'')
      io.write(v)
      io.write('\'\n')
    else
      io.write(tostring(v))
      io.write('\n')
    end
  end
end

function inspect.inspect(thing)
  local spotted = {}
  if type(thing) == 'table' then
    if thing.class_name then
      print(thing.class_name)
      if thing.prototypes then
        print('  supports ' .. json.encode(thing.prototypes))
      else
        print('  supports nothing')
      end
      if thing._class and array.contains(thing.prototypes, 'serializable') then
        print('  serialized: ')
        inspect.pretty_print_table(thing:serialize(), 2, nil, spotted)
      end
      print('  standard dump: ')
      inspect.pretty_print_table(thing, 2, nil, spotted)
    else
      print('generic ' .. tostring(thing))
      inspect.pretty_print_table(thing, 1)
    end
  else
    print(tostring(thing))
  end
end

return inspect
