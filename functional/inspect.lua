--- This module is used for inspecting things
-- It is specifically tuned for our object system.
-- It dumps using json
-- @module inspect

local json = require('json')
local array = require('functional/array')

local inspect = {}

function inspect.pretty_print_table(tabl, nest_level, indent_str, spotted, serialize)
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
        if not v.class_name then
          io.write('generic ' .. tostring(v))
        else
          io.write('instance ' .. string.sub(tostring(v), 8) .. ' of ' .. v.class_name)
        end
        io.write(' = {\n')
        inspect.pretty_print_table(v, nest_level + 1, indent_str, spotted, serialize)
        for i=1, nest_level do
          io.write(indent_str)
        end
        io.write('}')

        if serialize and array.contains(v.prototypes, 'serializable') then
          io.write('; when serialized, this = {\n')
          local serd = v:serialize()
          inspect.pretty_print_table(serd, nest_level + 1, indent_str, spotted, serialize)
          for i=1, nest_level do
            io.write(indent_str)
          end
          io.write('}; when THAT is deserialized, this = {\n')
          local deserd = v._wrapped_class.deserialize(serd)
          inspect.pretty_print_table(deserd, nest_level + 1, indent_str, spotted, false)for i=1, nest_level do
            io.write(indent_str)
          end
          io.write('}')
        end

        io.write('\n')
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

function inspect.inspect(thing, serialize)
  if serialize == nil then serialize = true end

  local spotted = {}
  if type(thing) == 'table' then
    if thing.class_name then
      print(thing.class_name)
      if thing.prototypes then
        print('  supports ' .. json.encode(thing.prototypes))
      else
        print('  supports nothing')
      end
      if serialize and thing._class and array.contains(thing.prototypes, 'serializable') then
        print('  serialized: ')
        inspect.pretty_print_table(thing:serialize(), 2, nil, spotted, serialize)
      end
      print('  standard dump: ')
      inspect.pretty_print_table(thing, 2, nil, spotted, serialize)
    else
      print('generic ' .. tostring(thing))
      inspect.pretty_print_table(thing, 1, nil, nil, serialize)
    end
  else
    print(tostring(thing))
  end
end

return inspect
