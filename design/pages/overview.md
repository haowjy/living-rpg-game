# Overview

Living RPG is a story-driven fantasy RPG performed by a polished game client
and directed at key moments by LLMs. It should feel like a game first: the
player walks through a persistent world, talks to people, enters Dungeons,
fights deterministic battles, and develops techniques and weapons. The Oracle
decides which remembered pressures deserve a scene.

## Player promise

**Start unknown. Become someone people remember. Build techniques and weapons
that carry the history of your run.**

The world remembers what the player did, who witnessed it, what people asked
of them, and which promises they kept. Those facts return through dialogue,
rumors, relationships, access, conflict, and opportunities. The result should
feel authored without following a fixed campaign.

## How the game works

```text
player, deterministic AI, or LLM
                |
                v
        validated commands
                |
                v
      deterministic simulation
                |
                v
         canonical events
                |
                v
       presentation and memory
```

- **Deterministic systems** own movement, time, schedules, inventory, legal
  actions, battle resolution, spawning, and state mutation.
- **LLMs** choose or write meaningful material: Oracle scenes, character
  dialogue, optional battle decisions, story-thread interpretation, and upgrade
  proposals.
- **Presentation** turns commands and events into movement, animation, camera
  work, portraits, dialogue, effects, sound, and mobile UI.

Every LLM path needs a schema, validator, trace, and deterministic fallback.

## Experience loop

1. **Move through the world.** Explore authored settlements and a persistent,
   once-generated overworld.
2. **Deal with people.** Hear requests, make promises, negotiate, refuse, help,
   disappoint, and build a reputation.
3. **Enter Dungeons.** Explore repeatedly generated monster spaces for danger,
   materials, weapons, and techniques.
4. **Fight.** Choose legal actions in deterministic turn-based battles against
   enemies controlled by priority AI, utility AI, or an LLM battle controller.
5. **Develop power.** Practice techniques, craft and reforge equipment, then
   ask the Oracle to propose upgrades within mechanical budgets.
6. **Return to consequences.** Time passes, people act, and the Oracle surfaces
   the pressure created by what happened or was neglected.

## Story without a quest log

There are no task cards, objective counters, completion popups, or automatic
failure messages. A person asks for something. The world records what was said,
whether the player promised, and what later occurred. The requester may remember
that the player helped, refused, or forgot.

The Oracle may track requests and living story threads internally. Players
experience them as relationships and situations rather than a list of chores.

## First proof

The first playable slice is a small presentation sandbox containing:

- one attractive settlement area and interior;
- four or five named people;
- one request whose consequence can return later;
- one repeatedly generated Dungeon;
- one deterministic battle sequence with several techniques;
- one technique evolution or weapon reforge proposed through a validated LLM
  interface;
- a Director console that can stage the same scene as an authored script or an
  LLM.

The slice succeeds when the presentation feels worth controlling and the world
can remember a small event well enough to make its later consequence personal.

## Scope boundaries

The first slice does not need a simulated continent, full economy, spirit
collection, elaborate faction management, or a finished autonomous Oracle.
TypeScript is the current preference, but the engine and framework remain open
until the Director and presentation spike prove the right fit.
