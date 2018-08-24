--- Describes something that listens for an ability.
-- Most abilities only need one listener, but they might
-- might need to break it up amongst multiple files.
--
-- Some control over the order of listeners is provided.
-- If we need finer tuned granularity it's likely best
-- to modify this prototype and update the listener manager.

local prototype = require('prototypes/prototype')

prototype.register('ability_listener', {
  --- Returns which ability this listener is listening
  -- to.
  -- @treturn string the classname of the ability to listen for
  'get_listen_ability',

  --- Determines the order of this listener with respect to
  -- the given listener. In this case, the listener is an
  -- ability listener.
  --
  -- If this returns -1, this listener will go prior to the
  -- specified listener. If this returns 0, then the order
  -- will be decided either arbitrarily or by the other listener.
  -- If this returns 1, this listener will go after the specified
  -- listener. If the listeners return the same thing, an
  -- error is thrown.
  --
  -- @tparam string listener the class name for the other listener
  -- @treturn number -1 (this first), 0 (I don't care), or 1 (this second)
  'compare_listener',

  --- Determines if we can start a given ability.
  -- This acts like a local ability event pre listener,
  -- except it isn't called if we'e already determined
  -- the ability is unsuccessful.
  --
  -- This is run locally on the server, so it does not
  -- need to be deterministic.
  --
  -- @tparam GameContext game_ctx the game context
  -- @tparam LocalContext local_ctx the local context
  -- @tparam Event event the event we're trying to start
  -- @treturn boolean true if we can start the ability, false otherwise
  'can_start_ability',

  --- Callback for the abilities success at starting having been determined.
  --
  -- @tparam GameContext game_ctx the game context
  -- @tparam LocalContext local_ctx the local context
  -- @tparam Event event the event that we considered starting
  -- @tparam boolean success if we determined we can start the event
  'on_ability_start_determined',

  --- Callback for immediately prior to the event being set as the
  -- callback event for the adventurer.
  --
  -- For two-ability interactions this is a reasonable place to replace
  -- the ability based on the active ability.
  --
  -- Note that the AdventurerEvent keeps the event callback serialized.
  -- You typically do not need to deserialize it to get enough information
  -- on it. Access the serialized ability through
  -- event.ability.ability.serialized
  --
  -- @tparam GameContext game_ctx the game context
  -- @tparam LocalContext local_ctx the local context
  -- @tparam Networking networking the networking
  -- @tparam Event event the AdventurerEvent (type = 'ability')
  'pre_ability_started',

  --- Callback for immediately after the event has been set as the callback
  -- event for the adventurer.
  --
  -- This is the earliest you know for certain what the callback event
  -- will be. If you want to send out messages about the event, this
  -- is the earliest you can do that.
  --
  -- @tparam GameContext game_ctx the game context
  -- @tparam LocalContext local_ctx the local context
  -- @tparam Networking networking the networking
  -- @tparam Event event the AdventurerEvent (type = 'ability')
  'post_ability_started',

  --- Callback for pre/post ability progress events. This has granularity
  -- of at best once per second, and will also be called during the last
  -- tick.
  --
  -- @tparam GameContext game_ctx the game context
  -- @tparam LocalContext local_ctx the local context
  -- @tparam Networking networking the networking
  -- @tparam Event event the AbilityProgressEvent
  -- @tparam Event callback_event the event on the adventurer fetched for you already
  -- @tparam boolean pre if this is the pre listener (true) or post listener (false)
  'ability_progress',

  --- Callback for pre/post ability cancelled events.
  -- This occurs when something other than the AbilityProgressEvent
  -- nil's the active ability callback event on an adventurer.
  --
  -- @tparam GameContext game_ctx the game context
  -- @tparam LocalContext local_ctx the local context
  -- @tparam Networking networking the networking
  -- @tparam Event event the AbilityCancelledEvent
  -- @tparam boolean pre if this is the pre listener (true) or post listener (false)
  'ability_cancelled',

  --- Determines if we can finish the ability / if the ability
  -- was successful after the duration of the ability has elapsed.
  --
  -- Often you should incorporate the fail chance through the appropriate
  -- helper functional module if it makes sense for the ability at this
  -- stage.
  --
  -- @tparam GameContext game_ctx the game context
  -- @tparam LocalContext local_ctx the local context
  -- @tparam Event event the event we're trying to start
  -- @treturn boolean true if we can start the ability, false otherwise
  'can_finish_ability',

    --- Callback for the abilities success at finishing having been determined.
    --
    -- If 'success' is true, there's no turning back. The ability is going
    -- to be processed in the very near future.
    --
    -- @tparam GameContext game_ctx the game context
    -- @tparam LocalContext local_ctx the local context
    -- @tparam Event event the event that we considered finishing
    -- @tparam boolean success if we determined we can start the event
  'on_ability_finish_determined',

  --- Callback for just prior to the ability being processed.
  --
  -- @tparam GameContext game_ctx the game context
  -- @tparam LocalContext local_ctx the local context
  -- @tparam Networking networking the networking
  -- @tparam Event event the callback event we're about to process
  'pre_ability',

  --- Callback for just after the ability was processed.
  --
  -- @tparam GameContext game_ctx the game context
  -- @tparam LocalContext local_ctx the local context
  -- @tparam Networking networking the networking
  -- @tparam Event event the callback event we just processed
  'post_ability'
})
