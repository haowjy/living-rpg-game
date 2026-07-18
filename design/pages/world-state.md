# World State and Memory

Canonical state records facts independently of any model's context. LLMs may
read selected state and propose commands; only deterministic tools may change
what the world treats as true.

## State shape

The storage implementation remains open, but the world needs inspectable
records for:

```text
world
  clock and global pressures
  overworld seed and generated areas
  Dungeon definitions and active instances
  characters
    location, goals, plans, relationships
    knowledge, memories, requests, commitments
  factions
  items, weapons, and inventories
  techniques and proficiency
  living threads
  events
```

Structured files are useful because agents and developers can inspect them
directly. A database may own runtime queries later. Neither choice changes the
command and event boundary.

## Events establish history

Every consequential change produces an append-only event. An event includes:

- time and location;
- actors and witnesses;
- visibility;
- the command that produced it;
- factual consequences;
- tags or references needed for later retrieval.

Example:

```json
{
  "id": "evt-0042",
  "time": "day-3-18:10",
  "type": "commitment_unfulfilled",
  "location_id": "road-healer-camp",
  "actor_ids": ["player"],
  "witness_ids": [],
  "visibility": "private",
  "summary": "The warning had not reached the road healer before sundown.",
  "refs": ["request-feverroot-warning"]
}
```

The event records the missed outcome. It does not assert that the requester
knows, forgives, or condemns the player.

## Knowledge and memory

World truth and character knowledge are separate.

A person may react to a fact only if they:

- experienced it;
- witnessed it;
- received it through dialogue, a message, or a rumor;
- inferred it through a validated reasoning step.

Character memory stores references to known events plus personal interpretation
when that interpretation matters. Relationships may carry numeric axes for
deterministic rules, but remembered reasons remain available to dialogue and
the Oracle.

## Derived indexes

Full-text and semantic indexes help retrieve events, people, locations, and
themes. They are rebuildable projections, never canonical state. A failed or
stale index must not change the truth of the world.

Useful retrieval questions include:

- What happened here recently?
- What does this person know about the player?
- Which promises remain unresolved?
- Which events connect these people?
- What history is relevant to this technique or weapon?

## Save and replay

A save contains the canonical state, content versions, random seeds, and event
position needed to continue. Replaying the same commands from the same snapshot
must reproduce the same deterministic results. LLM prose may differ unless it
was recorded as an accepted scene artifact; state consequences may not.
