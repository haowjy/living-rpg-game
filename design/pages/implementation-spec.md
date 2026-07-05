# V0 Implementation Spec

This page is the build contract for the first playable prototype. It turns the design into concrete state files, tool contracts, validation rules, and a 30-60 minute starting-region happy path.

## Scope

V0 is a terminal-playable agent package with a small deterministic tool layer. The LLM writes narration and proposes actions. Tools own all state mutation, validation, indexing, and replayable logs.

In scope:

- One small authored starting region plus 6-8 connected sites.
- Player, 5 named NPC agents, and lightweight background NPCs.
- Location movement, event logging, relationships, rumors, quest threads, site control, technique proficiency, technique evolution, and shrine breakthroughs.
- Full-text search over world files. Vector search can be stubbed with keyword search until the first play loop works.
- Scenario tests that replay scripted sessions and verify world-state consistency.

Out of scope:

- Custom visual client.
- Real-time combat.
- Full visual turn-based combat UI.
- Procedural tile chunks.
- Fully simulated economy.
- Continental-scale NPC simulation.

## Canonical State

The file system is the source of truth. The index is derived and rebuildable. Agents may read files, but only tools may edit canonical files.

```text
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
  shrines/
  events/log.jsonl
  events/log.md
  index/
```

`log.jsonl` is canonical for events. `log.md` is a readable projection rebuilt from it.

## Entity Schemas

Use markdown for prose plus one fenced JSON block for machine state. Tools parse the JSON block and preserve surrounding prose when updating.

### Area

```json
{
  "id": "market-road",
  "name": "Market Road",
  "kind": "road_hub",
  "parent_area_id": "starting-region",
  "exits": ["old-shrine", "town-gate", "mill-road", "river-crossing"],
  "control": {"faction_id": "local-authority", "strength": 3},
  "danger": 1,
  "tags": ["public", "trade", "rumor_hub"],
  "present_character_ids": ["guild-clerk", "rival-adventurer"],
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

```json
{
  "id": "rival-adventurer",
  "name": "Rival Adventurer",
  "kind": "named_npc",
  "location_area_id": "market-road",
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

### Technique

```json
{
  "id": "wolf-step",
  "name": "Wolf Step",
  "owner_character_id": "player",
  "source": {"kind": "manual", "id": "hunter-footwork-manual"},
  "proficiency": {
    "level": "competent",
    "xp": 42,
    "next_level_xp": 60
  },
  "combat_shape": {
    "kind": "movement",
    "position_delta": 1,
    "target_rule": "self",
    "cooldown": 1,
    "effects": ["dodge_bonus"]
  },
  "evolution_history": [],
  "tags": ["movement", "evasion", "beast_style"]
}
```

Validation rules:

- Owner character must exist.
- Source must reference an existing manual, teacher, enemy observation, relic, shrine, or experiment event.
- Proficiency level must be one of: `untrained`, `novice`, `competent`, `expert`, `master`.
- Combat effects must map to known primitives.

### Shrine

```json
{
  "id": "old-road-shrine",
  "name": "Old Road Shrine",
  "location_area_id": "old-shrine",
  "allowed_breakthroughs": ["first-ember", "rain-vow", "stone-body"],
  "requirements": {
    "minimum_level": 1,
    "required_event_tags": ["survived_danger"]
  },
  "weirdness_ceiling": 1,
  "tags": ["shrine", "road", "forgotten_god"]
}
```

Validation rules:

- Shrine location must exist.
- Breakthrough ids must map to valid breakthrough definitions.
- Weirdness ceiling is 0-5.

### Event

`events/log.jsonl` stores one JSON object per line:

```json
{
  "id": "evt-0007",
  "day": 3,
  "hour": 13,
  "type": "public_confrontation",
  "location_area_id": "market-road",
  "actor_ids": ["player", "rival-adventurer"],
  "witness_character_ids": ["guild-clerk"],
  "faction_ids": ["adventurers-guild"],
  "visibility": "public",
  "summary": "The rival adventurer accused the player of taking guild work above their rank.",
  "consequences": [
    {"kind": "relationship_delta", "source_id": "rival-adventurer", "target_id": "player", "delta": -1},
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

### `record_training(character_id, technique_id, source, amount, context_event_id)`

Checks:

- Character and technique exist.
- Character owns or can train the technique.
- Source is legal: use, practice, manual, teacher, sparring, combat, exploration.
- Context event exists unless the training is a quiet downtime action.

Effects:

- Adds proficiency XP.
- Promotes proficiency level if threshold is crossed.
- Writes a training event.
- Adds relevant tags to the technique's history.

### `evolve_technique(proposal)`

Checks:

- Base technique exists and belongs to the player.
- Base technique proficiency meets the evolution threshold.
- References exist or are player-written text.
- Every effect maps to a known primitive.
- Budget is legal for tier, shrine path, and weirdness ceiling.
- The technique does not duplicate an existing player ability.

Effects:

- Creates a new evolved technique or updates the existing technique branch.
- Links references and relevant history events.
- Writes a technique-evolved event.

### `attempt_breakthrough(character_id, shrine_id, proposal)`

Checks:

- Character and shrine exist.
- Character is at the shrine or otherwise has valid access.
- Requirements are met.
- Proposed effects fit the shrine and current progression tier.

Effects:

- Updates player path, level/rank, element, bonuses, vows, curses, or weirdness ceiling.
- Writes a breakthrough event.
- Adds shrine knowledge to future technique evolution context.

## Turn-Based Combat Budget

V0 combat is narrative turns, but technique mechanics should be compatible with a later turn-based visual system.

| Tier | Budget | Example |
|---|---:|---|
| 1 | 3 points | Reposition plus dodge bonus |
| 2 | 5 points | Guard plus stress heal |
| 3 | 7 points | Mark plus fear pressure plus conditional damage |

Primitive costs:

| Primitive | Cost |
|---|---:|
| Minor damage, self reposition, reveal, dialogue unlock | 1 |
| Guard, push, pull, mark, morale buff, stress heal, stress damage, dodge bonus | 2 |
| Summon, terrain change, faction aura, reputation shift, multi-target status | 3 |

Modifiers:

- Cooldown reduces budget pressure only when it is meaningful in play.
- Oath condition, positioning restriction, or escalation risk may discount 1 point.
- Tier 1 techniques cannot affect factions or territory directly.
- Weird effects require an appropriate shrine breakthrough or path state.

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

## Starting-Region Happy Path

This is the first replay scenario for testing.

1. Player starts in a small authored hub.
2. Player learns a basic technique from a manual, teacher, or relic.
3. Player travels to a nearby pressured site.
4. Player resolves a conflict in a way that creates witnesses and consequences.
5. `write_event` records the action, witnesses, and visible outcomes.
6. `spread_rumor` moves the story back to the hub.
7. An NPC reacts publicly because they know the rumor, not because the player knows it.
8. The story sifter promotes a rivalry or site thread based on pressure score.
9. The player trains or uses the basic technique enough to increase proficiency.
10. The player reaches a mastery threshold and evolves the technique using a chosen reference.
11. The player visits a shrine and attempts a simple breakthrough.

Passing criteria:

- Every NPC reaction is backed by event knowledge or rumor knowledge.
- Every scene references a reachable area or a message carrier.
- The event log explains the whole story without hidden state.
- Technique proficiency changes are traceable to use, practice, study, or training.
- Technique evolution uses explicit references plus retrieved history.
- Shrine breakthrough changes are recorded and influence later evolution validation.
- A fresh index rebuild produces the same reachable facts.

## Scenario Tests

Minimum test suite:

- `movement-adjacency`: invalid non-adjacent movement is rejected.
- `knowledge-boundary`: an NPC cannot react to an unknown private event.
- `rumor-propagation`: a rumor moves between areas through a carrier.
- `quest-promotion`: pressure score 6 creates a quest thread.
- `training-proficiency`: training/use increments a technique and promotes level at threshold.
- `technique-evolution-budget`: an over-budget evolution proposal is rejected.
- `shrine-breakthrough`: invalid shrine access or unmet requirements are rejected.
- `event-replay`: rebuilding projections from `log.jsonl` reproduces area recent events, character knowledge, technique proficiency, and shrine path state.