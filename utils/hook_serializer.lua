--- This describes something that uses hooks for serialization.
-- This is best used in situations where other classes might
-- want to inject stuff into your class that are too complicated
-- for the simple serializer
--
-- @module hook_serializer

local array = require('functional/array')

local hook_serializer = {}

-- region implementation
local function simple_serializer_hook(self, copy, k, v)
  if type(v) == 'table' then
    copy[k] = array.public_primitives_deep_copy(v)
  else
    copy[k] = v
  end
end

local function simple_deserializer_hook(cls, serd, copy, k, v)
  simple_serializer_hook(serd, copy, k, v)
end

local function deserializer_as_array_hook(cls, serd, copy, k, v)
  local my_copy = {}
  for n,m in pairs(v) do
    my_copy[tonumber(n)] = m
  end
  copy[k] = my_copy
end

local function inject_add_serialize_hook(self, name, hook)
  if not self._class._serialize_hooks then
    self._class._serialize_hooks = {}
  end

  if self._class._serialize_hooks[name] then
    error('There already exists a serialize hook for ' .. self.class_name .. ' for ' .. name)
  end

  if not hook then
    hook = simple_serializer_hook
  end

  self._class._serialize_hooks[name] = hook
end

local function inject_add_deserialize_hook(self, name, hook)
  if not self._class._deserialize_hooks then
    self._class._deserialize_hooks = {}
  end

  if self._class._deserialize_hooks[name] then
    error('There already exists a deserialize hook for ' .. self.class_name .. ' for ' .. name)
  end

  if not hook then
    hook = simple_deserializer_hook
  elseif hook == 'numeric_keys' then
    hook = deserializer_as_array_hook
  end

  self._class._deserialize_hooks[name] = hook
end

local function inject_add_context_changed_hook(self, name, hook)
  if not self._class._context_changed_hooks then
    self._class._context_changed_hooks = {}
  end

  if self._class._context_changed_hooks[name] then
    error('There already exists a context changed hook for .. ' .. self.class_name .. ' for ' .. name)
  end

  if not hook then
    error('There isn\'t a default hook for context changed!')
  end

  self._class._context_changed_hooks[name] = hook
end

local function inject_serialize(self)
  local copy = {}
  for k,v in pairs(self) do
    if type(k) == 'string' and k:sub(1, 1) ~= '_' then
      if not self._class._serialize_hooks then
        error('Missing serialize hook for key ' .. k)
      end

      local hook = self._class._serialize_hooks[k]
      if not hook then
        error('Missing serialize hook for key ' .. k)
      end

      hook(self, copy, k, v)
    end
  end

  return copy
end

local function create_inject_deserialize(cls)
  return function(serd)
    local copy = {}
    for k,v in pairs(serd) do
      if not cls._deserialize_hooks then
        error('Missing deserialize hook for ' .. tostring(k) .. '; this could be an invalid argument or implementation error', 3)
      end

      local hook = cls._deserialize_hooks[k]
      if not hook then
        error('Missing deserialize hook for ' .. tostring(k) .. '; this could be an invalid argument or implementation error', 3)
      end

      hook(cls, serd, copy, k, v)
    end
    local result = cls._wrapped_class:new(copy)
    return result
  end
end

local function inject_context_changed(self, game_ctx)
  if not self._class._context_changed_hooks then return end

  for k,v in pairs(self) do
    local hook = self._class._context_changed_hooks[k]
    if hook then
      hook(self, game_ctx, k, v)
    end
  end
end
-- endregion

--- Inject the functions into the given class for serialization
--
-- @tparam table cls the class before a call to class#create
function hook_serializer.inject(cls)
  --- Add the given hook for serializing the given thing
  --
  -- The hook is a function of the form
  --   function(self, copy, k, v)
  --
  --   self - the table that needs to be serialized
  --   copy - the table that is being serialized into
  --   k    - the key that this hook is meant to serialize
  --   v    - the value that should be serialized
  --
  -- If the hook is nil, then it just does a primitives copy of that key
  -- as if by the simple serializer
  --
  -- @tparam string name the name of the thing to serialize
  -- @tparam function hook the hook to use, nil for the simple serialize method
  cls.add_serialize_hook = inject_add_serialize_hook

  --- Add the given hook for deserializing the given thing
  --
  -- The hook is a function of the form
  --   function(cls, serd, copy, k, v)
  --
  --   cls  - the class that is deserializing
  --   serd - the serialized table that was fetched from serialize
  --   copy - the table that will be passed as arguments to new
  --   k    - the key to deserialize that is in serd
  --   v    - the value of the key in serd
  --
  -- If the hook is nil, then it just copies it as-is to the arguments,
  -- as if by the simple serializer
  --
  -- @tparam string name the name of the thing to deserialize
  -- @tparam function hook the hook to deserialize the thing
  cls.add_deserialize_hook = inject_add_deserialize_hook

  --- Add the given hook for when context changes
  --
  -- The hook is a function of the form
  --   function(self, gctx, k, v)
  --
  --   self - the table of the class that needs to handle context changing
  --   gctx - the new game context
  --   k    - the key that this hook is handling
  --   v    - the value self[k]
  --
  -- If the hook is nil, an error is thrown.
  --
  -- @tparam string name the name of the thing to handle with this hook
  -- @tparam function hook the hook that handles the thing
  cls.add_context_changed_hook = inject_add_context_changed_hook

  cls.serialize = inject_serialize
  cls.deserialize = create_inject_deserialize(cls)
  cls.context_changed = inject_context_changed
end

return hook_serializer
