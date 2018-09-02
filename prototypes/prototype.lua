--- This type of thing ensures that a class implements
-- all of the methods described by a prototype in a viable
-- way.
--
-- @module prototype

local prototype = {}

--- All the registered prototypes.
--
-- The keys are the name of the prototype, the value is a
-- table of arrays of strings that refer to required function
-- names.
prototype.known = {}

--- Registers a new prototype with the given style.
--
-- @tparam string name the name of the prototype
-- @tparam {string,...} style the names of required functions
function prototype.register(name, style)
  if prototype.known[name] then
    error('There is already a prototype by the name ' .. name, 2)
  end

  prototype.known[name] = style
end

--- Make the promise that the given class supports the given prototype.
-- This will verify the promise and add it to the prototypes table
-- of the class. Note that this should be called prior to the actual
-- class#create call.
--
-- @tparam table cls the class that should support the prototype
-- @tparam string name the prototype that you support
function prototype.support(cls, name)
  local clsname = cls.class_name or tostring(cls)

  if not prototype.known[name] then
    error('There is no prototype by the name ' .. name .. ' for ' .. clsname .. ' to support', 2)
  end

  local ptype = prototype.known[name]
  for _, fn in ipairs(ptype) do
    if type(cls[fn]) ~= 'function' then
      error('The class ' .. clsname .. ' does not implement ' .. fn .. ' of ' .. name, 2)
    end
  end

  if not cls.prototypes then
    cls.prototypes = {}
  end

  cls.prototypes[#cls.prototypes + 1] = name
end

--- Determine if the given class supports the given prototype
-- @tparam table cls the class that should support the prototype
-- @tparam string name the prototype you want to detect
-- @treturn boolean true if cls supports prototype, false otherwise
function prototype.is_supported_by(cls, name)
  if not cls.prototypes then return false end

  for _, p in ipairs(cls.prototypes) do
    if p == name then return true end
  end

  return false
end

return prototype
