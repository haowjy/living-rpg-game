# Story Oracle

The Oracle decides which unresolved pressure deserves attention at a moment
when the game can stage a scene. It does not write directly into world state,
move actors illegally, or turn every request into a quest.

## Trigger points

The Oracle runs at bounded moments rather than continuously:

- entering a location;
- beginning or ending a conversation;
- resting, waiting, or traveling;
- finishing a battle;
- reaching a request deadline or learning of a broken promise;
- completing a regional or major world tick.

Ordinary movement, schedules, spawning, and combat turns continue without it.

## Context

Before requesting a scene, the game assembles:

- the player's location and current activity;
- people present or able to communicate;
- what each participant knows and remembers;
- recent local events;
- unresolved requests and commitments;
- active relationships and faction pressures;
- available presentation resources and scene limits.

Retrieval narrows history to relevant facts. Canonical state remains outside
the model.

## Pressure and living threads

Story pressure is unresolved tension attached to people, places, factions, or
promises. A repeated conflict, an unanswered request, a rumor reaching the
wrong person, or a Dungeon surge may become a living thread.

Threads are internal context, not player-facing task objects. The Oracle may
connect several events into a rivalry, rescue, scarcity, legitimacy, or
betrayal thread when the connection creates a meaningful future choice.

See [People, Requests, and Threads](requests-threads.md) for the underlying
model.

## Scene proposal

The Oracle proposes:

1. the pressure to surface;
2. the participants and their immediate intentions;
3. the scene's dramatic turn;
4. dialogue or a dialogue brief;
5. Director cues the client can perform;
6. legal simulation commands to request if the scene changes state;
7. several player responses when a choice is appropriate.

The proposal remains provisional until validated.

## Validation

| Check | Required answer |
|---|---|
| Presence | Is each participant present, reachable, or using a valid messenger? |
| Knowledge | Does each person know the facts behind their reaction? |
| Causality | Does the scene follow from recorded events and current pressure? |
| Legality | Are proposed state changes expressible through valid commands? |
| Character | Does the action serve the person's goals, memory, and relationship state? |
| Scope | Can the current presentation perform the scene clearly? |
| Repetition | Has a similar beat already fired too recently? |

The game may repair one invalid proposal. If it still fails, an authored or
deterministic fallback preserves flow.

## What the Oracle may create

The Oracle can create meaning around validated primitives: conversations,
requests, rumors, living threads, faction initiatives, unusual Dungeon events,
technique proposals, and weapon histories. It cannot invent an entity as
already present, grant an illegal reward, or declare a consequence that the
simulation did not record.
