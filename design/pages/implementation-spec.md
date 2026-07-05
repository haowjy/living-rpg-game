# V0 Implementation Spec

This page is the build contract for the first playable prototype. It turns the design into concrete state files, tool contracts, validation rules, and a 30-60 minute Greyford happy path.

## Scope

V0 is a terminal-playable agent package with a small deterministic tool layer. The LLM writes narration and proposes actions. Tools own all state mutation, validation, indexing, and replayable logs.

In scope:

- Greyford plus 6-8 connected sites.
- Player, 5 named NPC agents, and lightweight background NPCs.
- Location movement, event logging, relationships, rumors, quest threads, site control, and insight technique creation.
- Full-text search over world files. Vector search can be stubbed with keyword search until the first play loop works.
- Scenario tests that replay scripted sessions and verify world-state consistency.

Out of scope:

- Custom visual client.
- Real-time combat.
- Procedural tile chunks.
- Fully simulated economy.
- Continental-scale NPC simulation.

## Canonical State

The file system is the source of truth. The index is derived and rebuildable. Agents may read files, but only tools may edit canonical files.

```
world/
  manifest.json
  world.md
  clock.json
  areas/
  characters/
  factions/
  quests/
  rumors/
  techniques/
  events/log.jsonl
  events/log.md
  index/
```

`log.jsonl` is canonical for events. `log.md` is a readable projection rebuilt from it.

## Entity Schemas

Use markdown for prose plus one fenced JSON block for machine state. Tools parse the JSON block and preserve surrounding prose when updating.

### Area

Required fields:

```json
{
  "id": "greyford-market",
  "name": "Greyford Market",
  "kind": "town_district",
  "parent_area_id": "greyford",
  "exits": ["church-hospital", "east-gate", "adventurers-guild", "old-wall-slums"],
  "control": {"faction_id": "vael-lordship", "strength": 3},
  "danger": 1,
  "tags": ["public", "trade", "rumor_hub"],
  "present_character_ids": ["mara-guild-clerk", "tomas-rival"],
  "known_rumor_ids": [],
  "active_pressure_ids": []
}
```

Validation rules:

- Every exit must reference an existing area.
- `present_character_ids` must match character `location_area_id`.
- `control.faction_id` must reference an existing faction.
- `danger` is 0-5 in V0.

### Character

Required fields:

```json
{
  "id": "tomas-rival",
  "name": "Tomas",
  "kind": "named_npc",
  "location_area_id": "greyford-market",
  "faction_id": "adventurers-guild",
  "stats": {"str": 11, "dex": 13, "con": 10, "int": 10, "wis": 9, "cha": 12, "hp": 18, "level": 1},
  "relationships": {"player": -1},
  "knowledge_event_ids": [],
  "known_rumor_ids": [],
  "goals": ["gain guild status", "avoid public humiliation"],
  "flags": []
}
```

Validation rules:

- Character location must exist.
- Named NPCs need at least one goal.
- Relationship values are integers from -5 to 5.
- A character can react only to events in `knowledge_event_ids`, rumors in `known_rumor_ids`, events where they were an actor or witness, or public events in their current area.

### Faction

Required fields:

```json
{
  "id": "red-sash-bandits",
  "name": "Red Sashes",
  "resources": {"food": 1, "coin": 1, "fighters": 3, "legitimacy": -2},
  "relationships": {"vael-lordship": -4, "greyford-villagers": -2},
  "controlled_area_ids": ["red-sash-camp"],
  "goals": ["hold the North Mill", "recruit useful locals"]
}
```

Validation rules:

- Resource values are -5 to 5.
- Controlled areas must exist and agree with the area `control` field.

### Rumor

Required fields:

```json
{
  "id": "rumor-arrogant-newcomer",
  "claim": "The newcomer is taking Guild work above their rank.",
  "source_event_id": "evt-0007",
  "origin_area_id": "greyford-market",
  "known_area_ids": ["greyford-market"],
  "known_character_ids": ["mara-guild-clerk", "tomas-rival"],
  "truth_status": "partial",
  "heat": 2
}
```

Validation rules:

- Rumors must originate from a real event.
- `truth_status` is `true`, `false`, `partial`, or `unknown`.
- `heat` is 0-5 and decays during quiet ticks.

### Quest Thread

Required fields:

```json
{
  "id": "reclaim-north-mill",
  "status": "active",
  "primary_area_id": "north-mill",
  "involved_area_ids": ["greyford-market", "north-mill", "red-sash-camp"],
  "involved_character_ids": ["mara-guild-clerk", "dusk-bandit-scout"],
  "involved_faction_ids": ["vael-lordship", "red-sash-bandits", "greyford-villagers"],
  "source_event_ids": ["evt-0003", "evt-0005"],
  "pressure_score": 6,
  "stakes": ["food supply", "lordship legitimacy", "player reputation"],
  "open_choices": ["destroy bandits", "recruit bandits", "return mill to villagers", "claim mill"]
}
```

Validation rules:

- Quest threads need at least one source event.
- Active quest threads need one primary area and at least two open choices.
- Resolved threads record the event that resolved them.

### Event

`events/log.jsonl` stores one JSON object per line:

```json
{
  "id": "evt-0007",
  "day": 3,
  "hour": 13,
  "type": "public_confrontation",
  "location_area_id": "greyford-market",
  "actor_ids": ["player", "tomas-rival"],
  "witness_character_ids": ["mara-guild-clerk"],
  "faction_ids": ["adventurers-guild"],
  "visibility": "public",
  "summary": "Tomas accused the player of taking Guild work above their rank.",
  "consequences": [
    {"kind": "relationship_delta", "source_id": "tomas-rival", "target_id": "player", "delta": -1},
    {"kind": "rumor_created", "rumor_id": "rumor-arrogant-newcomer"}
  ],
  "tags": ["rivalry", "guild", "reputation"]
}
```

Validation rules:

- Events are append-only.
- Every referenced entity must exist.
- Non-public events are known only to actors, witnesses, and later rumor recipients.
- Event time cannot move backward.

## Tool Contracts

Tools return either `{ "ok": true, "changes": [...] }` or `{ "ok": false, "error": "...", "retry_hint": "..." }`.

### `move_character(character_id, destination_area_id, reason)`

Checks:

- Character and destination exist.
- Destination is adjacent to the character's current area unless another tool grants travel.
- Character is not blocked by injury, captivity, or scene lock.

Effects:

- Updates source and destination `present_character_ids`.
- Updates character `location_area_id`.
- Writes a movement event unless `silent` is explicitly true for background ticks.

### `write_event(event)`

Checks:

- Required event fields are present.
- Actors are present, reachable, or acting through a message.
- Visibility and witness rules are coherent.
- Consequences reference legal tool effect kinds.

Effects:

- Appends to `events/log.jsonl`.
- Rebuilds `events/log.md`.
- Adds knowledge to actors and witnesses.
- Updates area recent events.

### `change_relationship(source_id, target_id, delta, reason_event_id)`

Checks:

- Source and target exist.
- Delta is -2 to 2 per call.
- Reason event exists and is known to the source, unless the source directly witnessed it.

Effects:

- Clamps relationship to -5 to 5.
- Writes a relationship consequence event or attaches to an existing event.

### `spread_rumor(rumor_id, from_area_id, to_area_id, carrier_id)`

Checks:

- Rumor exists in `from_area_id`.
- Areas are adjacent or connected by a known travel route.
- Carrier knows the rumor and can plausibly travel or send word.

Effects:

- Adds rumor to destination area.
- Adds rumor knowledge to present characters based on visibility.
- Increases or decays rumor heat.

### `claim_site(faction_id, area_id, strength, reason_event_id)`

Checks:

- Faction and area exist.
- Reason event supports the control change.
- Strength is 1-5.

Effects:

- Updates area control.
- Updates faction controlled areas.
- Writes a control-change event.

### `create_quest_thread(quest)`

Checks:

- Source events exist.
- Involved entities exist.
- Pressure score is at least 4.
- There are at least two plausible future choices.

Effects:

- Creates or updates a quest file.
- Links quest id into involved areas, characters, and factions.

### `create_technique(proposal)`

Checks:

- Source insight event exists.
- Every effect maps to a known primitive.
- Budget is legal for tier.
- The technique does not duplicate an existing player ability.

Effects:

- Creates a technique file.
- Adds technique id to the player.
- Writes a technique-created event.

## Pressure Scoring

Story sifting remains LLM-assisted, but promotion uses a deterministic score so it is inspectable.

| Signal | Points |
|---|---:|
| Repeated tag or actor cluster across 2+ events | 1 |
| Named NPC involved | 1 |
| Faction involved | 1 |
| Site control, injury, resource, or reputation at risk | 2 |
| Player has at least two plausible choices | 1 |
| Rumor has reached a new area or wrong person | 1 |
| Clock pressure exists within 1-2 days | 1 |

Promotion thresholds:

- 0-2: flavor or local color.
- 3: rumor or background pressure.
- 4-5: candidate scene.
- 6+: quest thread.

The LLM proposes the interpretation. The score determines whether the proposal can enter canonical quest state.

## Insight Spellcraft Budget

V0 techniques are narrative actions first, but they still need bounded mechanics for V1 compatibility.

| Tier | Budget | Example |
|---|---:|---|
| 1 | 3 points | Short dash plus flanking tag |
| 2 | 5 points | Shield plus focus recovery |
| 3 | 7 points | Area fear plus mark |

Primitive costs:

| Primitive | Cost |
|---|---:|
| Minor damage, short dash, reveal, dialogue unlock | 1 |
| Shield, push, pull, mark, morale buff, fear pressure | 2 |
| Summon, terrain change, faction aura, reputation shift | 3 |

Modifiers:

- Cooldown reduces budget pressure only when it is meaningful in play.
- Oath condition or escalation risk may discount 1 point.
- Tier 1 techniques cannot affect factions or territory directly.

## Greyford Happy Path

This is the first replay scenario for testing.

1. Player starts in Greyford Market.
2. Mara points the player toward the North Mill dispute.
3. Player travels to North Mill.
4. Player confronts bandits and chooses to spare Dusk.
5. `write_event` records the spared scout and visible witnesses.
6. `spread_rumor` moves the story back to Greyford.
7. Tomas reacts publicly because he knows the rumor, not because the player knows it.
8. The story sifter promotes a rivalry or mill thread based on pressure score.
9. The player resolves the mill through one of at least two factionally meaningful outcomes.
10. The player earns one insight candidate tied to the lived sequence.

Passing criteria:

- Every NPC reaction is backed by event knowledge or rumor knowledge.
- Every scene references a reachable area or a message carrier.
- The event log explains the whole story without hidden state.
- A fresh index rebuild produces the same reachable facts.

## Scenario Tests

Minimum test suite:

- `movement-adjacency`: invalid non-adjacent movement is rejected.
- `knowledge-boundary`: an NPC cannot react to an unknown private event.
- `rumor-propagation`: a rumor moves from North Mill to Greyford through a carrier.
- `quest-promotion`: pressure score 6 creates a quest thread.
- `technique-budget`: an over-budget technique proposal is rejected.
- `event-replay`: rebuilding projections from `log.jsonl` reproduces area recent events and character knowledge.
