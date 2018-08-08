# Technical Overview

The game is implemented as a client-server lockstep multiplayer system running
on events. The local player can provide string input, delimited by newlines,
which is sent to the **command processor**. The command processor first sends this
to 'listener' commands, then 'explicit', 'implicit', and 'generic' commands in that order. Each command has the opportunity to handle the input, which prevents any further commands from processing the events, and may optionally raise events.

The events are then sent to the **networking manager**. If the local player is a client,
this simply passes it onto the server who sends it out to all the clients. If it
is the server, it queues the event onto the local event queue and passes it along
to all the clients. Upon a client receiving an event from the server, it queues
it onto the event queue.

The **event queue** is cycled through by first informing the **listener processor**
that we are about to process an event, which calls all the pre-listeners
associated with that event, then processing the event, informing the listener
processor that we just processed an event, which calls all the post-listeners.
Listeners may be ordered through use of a comparison function, which is given
the class of another listener and may return -1 to go before it, 0 for does
not matter, and 1 to go after it. Both directions are always checked, where
the results must either be a 0 and a direction (direction rules) or two
opposite directions. Global listeners are always called after event-specific
listeners.

## Players, Adventurers, and Specializations

**Player** refers to the physical computer that is connected to the server.
Players are assigned a player id from the host which can be used to reference
that specific connection. Typically this is only used to fetch the adventurer.

**Adventurer** refers to an in-game entity which interacts with the game-world.
Adventurers also are referred to by an id, and there is a one-to-one mapping
between players and adventurers. The adventurer contains all the customization,
such as its name when seen in the world. Adventurers also hold any transient
information that would not suitably fit in the specialization, such as where
the adventurer is, any blessings or curses, their ability cooldowns, if they
are tied up, etc.

**Specialization** refers to a group of commands and listeners that are
available to an adventurer when they are playing a particular role. A specialization
has no identifying characteristics. It acts as an easy way to bulk-add and
remove a large number of commands and listeners to an adventurer.

## Game Setup

The game starts in a setup phase while waiting for players to connect. When
a player connects he is immediately assigned an adventurer with a randomly
chosen name, but is permitted to change that name. Players are free to
communicate during this period.

The host may use this time to configure any game options, for example he might
ask that adventurer names are re-randomized once the game starts to make it more
difficult to metagame. Once the number of players and game settings are satisfactory,
the host starts the game. At this point, new players that connect are not given
an adventurer, though they may attach to unattached player-controllable adventurers
created by a disconnect or bots.

At the start of the game, each player is assigned a random specialization, such
that the teams are fairly balanced and according to any requirements set forth
by the specializations (for example, there must be exactly 2 twin witches). Any
bots (as specified during the pre-game setup) are spawned during this period as
well. The specializations will determine the location that the adventurers
are moved to.

## Game World

The **world** is loaded from the server at the start of game as well. The world
contains a list of locations, the time to move between them, and tags for the
location, which are simply strings, i.e., consecrated, outside, electrical-lighting,
outskirts.

From here, each location is assigned a location object which contains dynamic
attributes for the location, such as the light level, the adventurers inside
of it, and if there is a demonic trace or not.

## Gameplay

The bulk of the gameplay is implemented in specializations and the few
non-specialized commands like move, sleep, or note. The listeners and commands
of each specialization modify the adventurer, even flagging them as dead when
appropriate. They also might modify locations, for example leaving a demonic
trace when they enter a location.

The specialization commands are split from the generic commands in the commands array through use of the SpecializationCommandProcessor, which handles only 'explicit' commands but enforces slightly more rigid conventions, such as help text. The listeners are not differentiated and are simply always in the listener pool.

Many commands effects are modified by the receiving party; this is often achieved
through complex listener chains and custom events. For example, chance to fail
is a very common modifier, but it is often implemented subtly different. Here
is a fictional way that Oracle's ability **Sample Essence** might resolve on a client
from the perspective of someone trying to implement it (skipping all internal
networking), assuming somehow the oracle is fatigued, blessed, and in a room
with a Recruit.

- Adventurer 2 (player 1) types `/sampleessence John`
- `SampleEssenceCommand:parse` triggers and searches the location for an
adventurer named John and finds one, adventurer 3. It issues a SampleEssenceEvent with the target adventurer 3.
- `SampleEssenceEvent:process` raises a custom non-networked event `AbilityEvent` with empty `fail_effects` and `fail_resist_effects`
- `ExhaustionListener:process` is called with the `AbilityEvent`. It notices that adventurer 2
is fatigued, so adds a 50% chance to fail to the array, with no callbacks.
- `LightLevelListener:process` is called with the `AbilityEvent`. The light level is well-lit,
so this does nothing.
- `BlessedListener:process` is called with the `AbilityEvent`. It notices adventurer 2 is
blessed, so adds a 25% fail resistance to the event with no callbacks.
- `CursedListener:process` is called with the `AbilityEvent`. Adventurer 2 is not cursed, so
it does nothing.
- `RecruitListener:process` is called with the `AbilityEvent`. Adventurer 2 is in an area with
a recruit, so it adds a 1% fail resistance to the event with no callbacks.
- `SampleEssenceEvent:process` now has a fully resolved `AbilityEvent`. It uses
`FailHelper` to determine that the ability did not fail.
- `SampleEssenceEvent:process` Notes that this information must be networked, so it raises a SampleEssenceEvent event that indicates failure has already been determined. (This may instead be done with a SampleEssenceSuccessEvent and SampleEssenceFailureEvent if desired). It must be done prior to the post-listeners as this allows other events to decide if they want to network events before or after the SampleEssenceEvent.
- `SampleEssenceEvent:process` calls the post-listeners for the `AbilityEvent`
 with failed set to false. These may raise additional events.
- `SampleEssenceEvent:process` completes
- `SampleEssenceEvent:process` is called, now knowing the event succeeded
- `SampleEssenceEvent:process` adds John to the sampled essences of the user, then
issues a non-networked `SystemInformationEvent` for itself, the target, and anyone
in the location. Some or all of these events might be suppressed via moving shadows.
- `SampleEssenceEvent:process` completes

Note that targeting might be done through a non-networked event as well, but
the SampleEssenceCommand would be blind to this. Non-networked events act as
an easy way to use the listener system in a way very similar to the modifier
system you often see in real time strategy games. The performance penalty is
not relevant in a text-based game.

Note that it is expected to do an additional circle at the beginning of the
resolve to ensure the result is determined by the server rather than the client.
