--- Registers the saveable prototype

local prototype = require('prototypes/prototype')

prototype.register('serializable', {
  --- Serialize the object to a table of primitives.
  -- This specifically serializes to a table, potentially nested,
  -- with no recursion and no metatables or metamethods on any
  -- tables, such that everything in the table follows those restrictions
  -- and any non-table objects are either strings or numbers.
  --
  -- @tparam table self reference to thing being serialized
  -- @treturn table primitives table
  'serialize',

  --- This is invoked when the context changes.
  -- It is passed the current game context. This allows the prototype
  -- to make references directly to things in the game without worrying
  -- about leaking memory, assuming it destroys all references and
  -- recreates them when this function is called.
  --
  -- @tparam table self reference to me
  -- @tparam GameContext game_ctx the state of the game
  'context_changed',

  --- Deserialize the object that was serialized via primitives
  -- This is NOT an instance function!
  --
  -- Create an instance of the object serialized using serialize
  --
  -- @tparam table serd the serialized table of primitives
  -- @treturn table an instance of a semantically similiar object
  'deserialize'
})
