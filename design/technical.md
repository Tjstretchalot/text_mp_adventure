# Technical Overview

The game is implemented as a client-server lockstep multiplayer server running
on events. The local player can provide string input, delimited by newlines,
which is sent to the command processor. The command processor first sends this
to 'listener' commands, then 'explicit', 'implicit', and 'generic' commands in that order.
Each command has the opportunity to handle the input, which prevents any further
commands from processing the events, and may optionally raise events.

The events are then sent to the networking manager. If the local player is a client,
this simply passes it onto the server who sends it out to all the clients. If it
is the server, it queues the event onto the local event queue and passes it along
to all the clients. Upon a client receiving an event from the server, it queues
it onto the event queue.

The event queue is cycled through by first informing the listener processor
that we are about to process an event, which calls all the pre-listeners
associated with that event, then processing the event, informing the listener
processor that we just processed an event, which calls all the post-listeners.
Listeners may be ordered through use of a comparison function, which is given
the class of another listener and may return -1 to go before it, 0 for does
not matter, and 1 to go after it. Both directions are always checked, where
the results must either be a 0 and a direction (direction rules) or two
opposite directions. Global listeners are always called after event-specific
listeners.
