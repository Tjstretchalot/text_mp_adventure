--- Utility file for creating classes
-- @module class

local class = {}

-- region Helper functions for init
local function injected_new(self, o)
  o = o or {}
  o._class = self._class
  setmetatable(o, getmetatable(self))

  if o.init then o:init() end

  return o
end

local function injected_index(self, key)
  local act = self._class[key]
  if act ~= nil then return act end
  return nil
end

-- endregion

--- Register the specified object as a class.
--
-- Class, in this case, is expected to be the table that will
-- be indexed by the implementing objects. This will inject a
-- new function, which will call the init function on the object
-- if it exists, after setting up the object.
--
-- The class may optionally specify a metatable, which must be
-- defined in 'mt'. This table is used for things like __str or
-- __repr. __index is special, and if it is implemented it will
-- be respected. The metatable will be removed from the class during
-- this function call.
--
-- In order to understand how to use this class, it's easiest to
-- see an example:
--
-- ```lua
-- -- foo.lua
-- require('classes/class')
-- local Foo = {}
-- Foo.mt = {}
--
-- function Foo.init(self)
--   print('self.bar = ' .. tostring(self.bar))
-- end
--
-- function Foo.baz(self)
--   print('Foo.baz')
-- end
--
-- class.create('foo', Foo)
--
-- return Foo
--
-- -- bar.lua
-- local Foo = require('foo')
--
-- local foo = Foo:new({ bar = 7 }) -- prints 'self.bar = 7'
-- foo:baz() -- prints 'Foo.baz'
-- ```
--
-- @tparam string class_name the name of the class
-- @tparam cls table the thing that should work like a class
-- @treturn table the class that you should return
function class.create(class_name, cls)
  if type(class_name) ~= 'string' then
    error('Didn\'t get a string as first argument to class.create; perhaps you got order backward? (cls=' .. tostring(cls) .. ')')
  end

  if getmetatable(cls) ~= nil then
    error('Class ' .. class_name .. ' has a metatable. Do not subclass!')
  end

  if cls.new then
    error('Class ' .. class_name .. ' defined new as ' .. type(cls.new) .. ' but that is meant to be injected', 2)
  end

  if cls.class_name then
    error('Class ' .. class_name .. ' defined class_name as ' .. type(cls.class_name) .. ' but that is meant to be injected', 2)
  end

  local mt = cls.mt or {}
  cls.mt = nil

  if mt.__index then
    local old_index = mt.__index
    mt.__index = function(self, key)
      local result = injected_index(self, key)
      if result == nil then return old_index(self, key) end
      return result
    end
  else
    mt.__index = injected_index
  end

  cls.new = injected_new
  cls.class_name = class_name

  local result = {}
  result._class = cls
  setmetatable(result, mt)

  cls._wrapped_class = result

  return result
end

--- Determine if the specified thing is a class
-- This checks if it was registered using class.create
--
-- @tparam table cls the class object
-- @treturn boolean true if cls is a class, false otherwise
function class.is_class(cls)
  if getmetatable(cls) == nil then return false end

  return type(cls.class_name) == 'string'
end

return class
