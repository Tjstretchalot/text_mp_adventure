# Demons and Slayers

## General

**Mechanic Notes**
- Chance to failure stacks multiplicatively. If you have a 30% chance to fail
an action and another 50% chance to fail, then you have `0.3 + (0.5 * 0.7) = 0.65`
65% chance of failure. Note order doesn't matter; `0.5 + (0.3 * 0.5) = 0.65`.
- Movement takes you from one zone to another adjacent zone. The map specifies
the time during the movement that is inside the first location and the time
during the movement that is inside the second location. Movements may not be
cancelled for any reason. The player is prevented from moving through impassable
locations, but if a location becomes impassable during a move the player
is immediately returned to his starting location and told why.

**Gameplay Notes**

Unless otherwise stated,

- All players may move between locations. Moving takes time (see map). Players
are alerted to movements through their location according to the light level.
- All players with vision on a location have a chance to see any actions
by players in that location, according to the light level.
- All abilities may be used once per cycle. Players with two abilities may
use both. Abilities act instantly unless they state otherwise.
- All players have **Short Sleep**: Sleep for 3 hours (11.25s at night, 16.875s
at day). Players do not receive messages while sleeping, may be tied up by a
single player, and do not defend attacks.
- All players have **Long Sleep**: Sleep for 6 hours (22.5s at night, 33.75s
at day). Players do not receive messages while sleeping, may be tied up by a
single player, and do not defend attacks.
- All demons give off a demonic trace in any location they enter, lasting one
cycle.
- All demons have the ability **Prove Demon** which proves they are a demon
to everyone in the location. **Prove Demon** does not have a cooldown.
- Some locations are consecrated. In these locations, demons:
  - use **Prove Demon** at start of day, with 5% chance of failure, boosted by
by the Twin Witches **Bless**
  - cannot voluntarily enter
  - have a 20% chance of death at start of day
  - have an 80% chance of failure for all actions
- Players may be tied up. When tied up, players have a 95% chance to fail all
actions unless freed. Tying up requires 1 hour (3.75s at night, 5.625s at day),
freeing is instant. Both require physical contact. Movement within zones is
instant once you arrive. It requires 3 players to tie up one other player.

Locations have a light level:
  - Brightly lit (sunny, standard clouds, torches, lighting)
  - Dimly lit (shadows) - 50% chance to detect other players
  - Darkness (inside without lighting) - 10% chance to detect other players.
50% chance of failure for all actions.

Players have a sleep requirement. They must sleep at least 6 hours (20s at
night or 34s at day) per day or suffer one level of exhaustion. Exhaustion is
cleared after 6 hours of rest.
Exhaustion levels are:

- **Tired**: 30% chance of failure on all actions
- **Fatigued**: 50% chance of failure on all actions
- **Exhausted**: 80% chance of failure on all actions, 50% chance to rest for the
entire period at start at night and start of day.

There are up to 12 players per round, 5 demons, 5 slayers, and 2 neutral. There
are also at least 20 non-player characters with no specialty. It is expected
that players will attempt to disguise themselves as these NPCs.

# Demons
## Main Objective

Assemble the 8 bones of the powerful ancient demon Gonthu to resurrect him,
restarting his reign. If both **Twin Witches** die, the demons can still force
a draw by killing all non-demon players.

Must also prevent the humans from using **Establish Protection**.

## Specialties

### Succubus

A powerful demon that presents itself in female form, known for her beauty
and the magically enhanced lust when in her presence.

#### Day Abilities

1. **Allure**: The target human can only hear your messages for 30 seconds
or until night (whichever comes sooner). 1 day cooldown. Cannot be used on the
same human on two consecutive days and requires physical contact. The target
cannot hurt you while allured. O
2. **Change Appearance**: Assume the appearance and name of a non-player
character. Requires physical access.

#### Night Abilities

1. **Seduce**: Prevents the target human from taking any action, and shares a
room with the target, leaving a demonic trace. Target must have been allured
during the day. The target human is told who the succubus is. Neither player
gets sleep during the night. Shares a cooldown with **Change Appearance**.
2. **Change Appearance**: Assume the appearance and name of a non-player
character. Requires physical access. Shares a cooldown with **Seduce**.


### Shapeshifter

A demon that is capable of transforming into various animals in order to serve
the demons.

#### Day Abilities

1. **Werecat**: Listen in on the target players location without announcing
your presence. Requires physical access.

#### Night Abilities

1.  **Werewolf**: Using your sense of smell, search a target location for bones.
Requires physical access. Grants bones in the target location. Has a 50% chance
of not being detected by other players at that location, except for other
werewolfs. While a werewolf, has **Darkness Master**: *Passive* No penalties
from light levels.


### Spectre

#### Day Abilities

1. **Sense**: Detect if there are any humans in the target location, and sense
any humans that have traversed through the location on the day used.

#### Night Abilities

1. **Attack**: Attack any players in the given location. If there are any demons
in the given location, the action fails and everyone in the location is told
who the Spectre is. Otherwise, the location is given a demonic trace and:
  - If there are no humans, nothing else happens
  - If there is 1 human:
    - the Spectre gets an additional 3% chance to fail this action
    - on failure, the human is told who the Spectre is
    - on success, the human dies
  - If there are 2 humans:
    - the Spectre gets an additional 25% chance to fail this action
    - on failure, the Spectre dies.
    - on success, the humans die
  - If there are 3+ humans:
    - the Spectre gets an additional 25% chance to fail *per human* (multiplicative)
    - on failure, the Spectre dies
    - on success, each human has a 90% chance of death, otherwise being alerted
to who the Spectre is.
2. **Sense**: Detect if there are any humans in the target location, and sense
any humans that have traversed through the location on the night used.

### Beelzebub

A beelzebub is a false god or idolator, and typically acts as a decision maker
for the demons and spreads information.

#### Day Abilities

1. **Disguise**: *Passive* Does not have a demonic trace. May enter consecrated
locations.
3. **Darkness Adept**: *Passive* Can see in all rooms as if they were one
light level higher (no change for Brightly lit)

#### Night Abilities

1. **Disguise**: *Passive* Does not have a demonic trace. May enter consecrated
locations.
2. **Command**: Forces the target to make an action, if it is possible for the
player to do so. If the player cannot, the target is told Beelzebub's
specialization.
3. **Darkness Adept**: *Passive* Can see in all rooms as if they were one
light level higher (no change for Brightly lit)

### Moving Shadow

The moving shadow cannot move into the light; it is killed if in a location
that has a light level of Dimly lit or higher. It waits, haunting anyone that enters
its location. Automatic lighting does not work in locations with a Moving Shadow.
Upon approval of the Moving Shadow, dead demons may assist it by using the Haunt
command as if they were the moving shadow.

At worst, a moving shadow acts as another source of **Curse** and as a way to
communicate with the dead. At best, it can cause humans to kill each other. The
moving shadow strongly incentivizes meeting outdoors or in consecrated locations.

#### Day Abilities

1. **Haunt**: Invade the conscious of the target player. Send
him a message as if they were from another player or from the system. Demons
are told that it is a moving shadow, allowing for targeted communication.
2. **Enhanced Haunt**: Only usable on humans with **Curse** during the day. See
night ability for usage.
3. **Darkness Master**: *Passive* No penalties from light levels
4. **Restless**: *Passive* Is not affected by exhaustion.
5. **Commune**: *Passive* Can speak with dead demons.
6. **Bringer of Darkness**: *Passive* Automatic lighting does not work in
the Moving Shadows location.
7. **Incorporeal**: *Passive* Cannot be harmed or tied up.

#### Night Abilities

1. **Enhanced Haunt**: Same as haunt, except that, for humans, all messages (from
anything other than moving shadows) are sent to the Moving Shadow instead of the
human, including day/night cycles. Also applies **Curse** (see Twin Witch) if
they do not already have it. Commands either have controls for overrides or
are not affected, to prevent them being used to detect a Moving Shadow. While a
moving shadow is able to use Enhanced Haunt on a human, the human is told the
room is Brightly Lit.
2. **Darkness Master**: *Passive* No penalties from light levels
3. **Restless**: *Passive* Is not affected by exhaustion.
4. **Commune**: *Passive* Can speak with dead demons.
5. **Bringer of Darkness**: *Passive* Automatic lighting does not work in
the Moving Shadows location.
6. **Incorporeal**: *Passive* Cannot be harmed or tied up.

### Twin Witch

The twin witch is guaranteed and always starts in pairs, with knowledge of who
the other is. The twin witches are capable of resurrecting Gonthu when they have
all their bones and serve as a powerful offensive with **Curse** that is hard to
trace since it only requires a name. Additionally, **Bless** can serve as an
incredibly strong bluffing tool since it helps the target resist **Prove Demon**
from consecrated locations.

#### Day Abilities

1. **Resurrect**: Requires a complete set of bones for Gonthu. Starts the reign
of Gonthu (requires 3 hours, 16.875s). Demons win if you do this.
2. **Curse**: Curses the target human, giving them a 2% chance to die
on start of day, doubling each day. Shares a cooldown with **Bless**. Does *not*
require physical access. The target is alerted on the 5th day of a curse (next
day is 64% chance of death) or 50% of the time when entering consecrated
locations (with a maximum of one roll per cycle).
They also have the same chance of failure as the followings days death chance.
3. **Bless**: Blesses the target demon. Starts with 0 uses available, shares
a cooldown with **Curse**. Requires physical access, and grants the target
demon 25% resistance to failure (subtractive; if they had a net chance of
failure of 65% they will have a net chance of failure of 90% after). A demon
may only blessed once, may target the twin witch.

#### Night Abilities

1. **Sacrifice**: The target tied up human is sacrificed for Gonthu, killing
the target and tells you the location of a piece of Gonthu's body that you have
not infused yet.
2. **Infuse**: The target bone of Gonthu is infused with power. Bones may only
be infused once per witch. For each infused bone, **Curse** starts one day later
and the witch is given one use of **Bless**. Both twin witches may infuse a bone,
gaining the effect separately.

### Demogorgon

Acting as a defensive force, typically assigned to the twin witch, the
demogorgon is too strong to attack head on and provides essential escape
abilities to key demons. The demogorgon still has to sleep

#### Day Abilities

1. **Alert**: *Passive* All attacks on the demogorgons location only attack
the demogorgon. Works even when sleeping.
2. **Strong**: *Passive* All attacks on a demogorgon have an additional 25% chance
of failure per demon in the demogorgons location, including the demogorgon,
stacking multiplicatively. Does not work when sleeping.
3. **Teleport**: Move the demogorgon and any demons in the same location to any **Outskirts**
location. Is not affected by the normal failure chance from being tied up.

#### Night Abilities

1. **Alert**: *Passive* All attacks on the demogorgons location only attack
the demogorgon. Works even when sleeping.
2. **Strong**: *Passive* All attacks on a demogorgon have an additional 25% chance
of failure per demon in the demogorgons location, including the demogorgon,
stacking multiplicatively. Does not work when sleeping.
3. **Teleport**: Move the demogorgon and any demons in the same location to any **Outskirts**
location. Is not affected by the normal failure chance from being tied up.
4. **Sacrifice**: The demogorgon gains **Restless**: *Passive* is not affected
by exhaustion. However, the demogorgon dies on the start of the 4th day following
this ability (including the next morning). Sacrifice can only be used once.

### Cursed Soul

The cursed soul acts as an alternative method to the Shapeshifter for acquiring
bones. The cursed soul does not have the similiar detection reduction, but
**Hustle** can make him harder to catch.

#### Day Abilities

1. **Search**: Search the target location for any bones of Gonthu. Requires
physical contact.
2. **Hustle**: The next movement happens at double speed. If tied, breaks
free without the failure chance from tied up, but has an additional 50% chance
to fail.

#### Night Abilities

1. **Search**: Search the target location for any bones of Gonthu. Requires
physical contact.
2. **Darkness Adept**: *Passive* Can see in all rooms as if they were one light
level higher (no change for Brightly lit)

## Slayers

### Main Objective

Use Establish Protection while preventing the demons from summoning Gonthu.


1. **Establish Protection**: Formed by training non-player characters. When there
are 12 human recruited members, the game enters *Sudden Death*. If human numbers
are not reduced below the threshold by the start of the following day, humans win.

#### Gameplay Notes

The humans are, in general, less varied than the demons and less individually
powerful. In groups of 3+ they are difficult to beat, however, they must weigh
this against the need to rapidly gather intelligence.

The slayer team is vaguely reminiscent of how you might expect old tribes to
run. There is a shot-caller, who maintains his control because of his ability
to gather information quickly, which is absolutely vital to the team. He can
also communicate with other humans from a distance, but only he can initiate
the conversation.

Humans do not have different abilities at day compared to night.

### Oracle

The oracle is weak in combat but excellent at communication. He tends to act
as the shotcaller.

Exactly one Oracle is guarranteed in every game.

#### Abilities

1. **Sample Essence**: Target a human in the same location and sample their
very essence, allowing you to find them later without physical contact. Requires
physical contact. Does not work if the target has a demonic trace.

2. **Send Message**: Send a message to a target human whose essence you've
previously sampled. No cooldown. The oracle is told if the target cannot be  
reached. Requires target is alive, awake, and not drugged.

3. **Final Prayer**: The oracle bestows his gift upon a target human whose
essence the oracle has sampled. If the oracle dies during the current cycle
(if used at night -> that night + following day. if used at day -> that day
\+ following night) then the target is converted to the Oracle. Target must be
a human. Success is not reported. 3 day cooldown.

### Deputy

The deputy has the best offensive tools for the humans. Due to the powerful
**Pass Badge** ability, he acts as a strong comeback tool as well, assuming
he is always in a location with another officer. Combined with **Alert**
demons should be very hesitant to attack groups containing the Deputy and
risk letting him get out of control.

Exactly one Deputy is guaranteed in every game.

#### Abilities

1. **Shoot**: Attempt to shoot the target in the same location. Upon success,
the target dies. 25% increased chance to fail. Cannot fail against tied up
targets. 5% chance to hit a random target in the same location on failure.
Cannot be used while tied up. Everyone in the location is alerted who fired
the shot, but not if the shot was successful.

2. **Show Badge**: Show the target your badge, indicating you are the Deputy.
No cooldown.

3. **Grapple**: Attempt to tie up the target. Upon success, the target
is tied up. 50% increased chance to fail. Everyone is alerted that you tried **Grapple** and its success.

4. **Escape**: Attempt to break free from tied-up. Can only be used when tied
up and does not suffer the normal penalty from being tied up. Has a 50%
increased chance to fail.

5. **Alert**: *Passive* All attacks on the Deputy's location only attack the
Deputy. Works even when sleeping.

6. **Pass Badge**: *Passive* Upon death, a random target without a demonic
trace in the Deputy's location is promoted. If the target is a human, he is granted **Vengeance**: 10% reduced chance to fail all actions. In addition, every **Vengeance** buff that the dead Deputy previously had is passed along.
If instead the target is a demon, he is just granted the **Shoot** and
**Show Badge** abilities. He is also granted **Fake Grapple**: Attempt to
tie up the target. Upon success, the target is tied up. 90% increased chance
to fail. Everyone is alerted that you tried **Grapple** and its success. If the Deputy dies to another human, this ability is not used.

7. **Train**: Attempt to train the target. If it is a non-player character he
is granted **Trained**: *Passive* Humans in the same location have a 1% reduced chance of failure. If the target already has 3 instances of
**Trained** then he converts to a Recruit. Requires 6 hours (22.5s at night,
  33.75s at day).

### Priest

The priest is crucial for sensing and removing curses or as a high-risk
high-reward mobile defensive option due to **Divine Eye** and **Divine
Intervention**. If the priest dies, the humans are on a strict time-limit
to finish the game before they die to the Twin Witches **Curse**.

At least one Priest is guaranteed in every game. No more than 2 priests spawn
in a single game.

#### Abilities

1. **Sense Curse**: Determines if the target is cursed. Requires 1 hour (3.75s
at night, 5.625s at day) of physical contact and has a 10% increased chance of failure.

2. **Remove Curse**: Removes the curse on the target, if there is one. Requires  3 hours (11.25s at night, 16.875s at day) of physical contact.

3. **Divine Eye**: *Passive* All demons have a 25% increased chance of failure
when performing actions in the Priests location. Failures caused this way force
the demon to use **Prove Demon**.

4. **Divine Intervention**: *Passive* When an ability hits the priest that
would cause death, the ability instead fails and the Priest loses **Divine
Intervention**. Nobody is told that this happened.

### Officer

The officer is the most common human type. They typically spend most of their
time training or protecting the other classes.

#### Abilities

1. **Attack**: Attack the target. Requires physical contact. 90% increased
chance to fail.

2. **Overwhelming Force**: *Passive* Other Officers in the same location have a 25% reduced chance to fail their **Attack** ability.

3. **Train**: Attempt to train the target. If it is a non-player character he
is granted **Trained**: *Passive* Humans in the same location have a 1% reduced chance of failure. If the target already has 3 instances of
**Trained** then he converts to a Recruit. Requires 6 hours (22.5s at night,
  33.75s at day).

### Recruit

Recruits are non-player characters that have been trained 3 times, and are
required to accomplish the **Enhanced Protection** victory condition. Recruits
will always go to the church if they are not in it, and will otherwise just
idle.

#### Abilities

1. **Trained**: *Passive* Humans in the same location have a 3% reduced chance
to fail all actions.
