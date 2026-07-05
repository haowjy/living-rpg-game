# Prototype

The proof-of-concept is a meridian package with a small deterministic tool layer. It proves persistent, local, escalating story in a small sandbox. After 30-60 minutes of play, the player should be able to tell a specific story that only happened because of their choices.

## Goal

The prototype is successful if the starting region feels like a place with memory: NPCs react to prior events, rumors move through the world, factions respond to the player's actions, techniques gain proficiency through use, and shrine breakthroughs can alter the player's path.

Do not anchor the prototype identity around a generic LLM-generated town name. Use placeholder names in tests if needed, but author the actual starting region deliberately.

## What to Build

The PoC is a meridian package containing:

| Component | Description |
|---|---|
| Game director agent | The main loop — reads world state, observes pressure, dispatches to other agents |
| Narrator agent | Generates prose from world state and scene context |
| Validator agent | Checks consistency — presence, knowledge, rules, causality |
| NPC agents | One per named character, using the character-sim pattern |
| World state files | The structured directory of prose and data files |
| Tool definitions | `move_character`, `write_event`, `change_relationship`, `spread_rumor`, `claim_site`, `create_quest_thread`, `record_training`, `evolve_technique`, `attempt_breakthrough` |
| Setup skill | Instructions for configuring local models as an alternative backend |

The build contract for these files and tools lives in [V0 Implementation Spec](implementation-spec.md).

## Vertical Slice

| Element | First version |
|---|---|
| Map | Small authored starting region + 6-8 connected sites |
| Characters | Player + 5 named agents + lightweight NPCs |
| Factions | Local authority, church/shrine institution, guild/company, bandits/raiders, villagers/refugees |
| Story threads | Site dispute, rival, shrine pressure, bandit recruitment, local legitimacy |
| World clock | Daily regional tick, hourly local tick, wait/travel triggers |
| Memory | Event log, area files, FTS + vector index |
| Technique system | One learned technique, proficiency gain, one evolution opportunity |
| Shrine system | One breakthrough site with a simple path upgrade |

## Player Interaction

The player interacts through natural language. Core actions:

- **look** — Describe the current area, exits, and present characters.
- **move** — Travel to an adjacent area.
- **talk** — Speak to a present character.
- **wait** — Advance the clock and trigger background actions.
- **inspect** — Examine something in detail.
- **train** — Practice a known technique or study a manual.
- **evolve** — At mastery, evolve a technique using chosen references.
- **pray / breakthrough** — Use a shrine, statue, or altar for path-level progression.
- **take job** — Accept a quest or task.

Example session:

```text
Day 1, Hour 9 — Market Road

Rain has turned the trade road into black mud. Refugees huddle beneath
patched canvas while a shrine bell rings somewhere beyond the old wall.
A guild clerk is arguing with a farmer over missing grain wagons.

Exits: north Old Shrine · east Town Gate
       west Mill Road · south River Crossing
Present: Guild Clerk, Rival Adventurer, Old Farmer

> inspect the shrine bell
```

## Success Criteria

1. The player always knows where they are and what exits/options exist.
2. Generated scenes only use reachable locations, present characters, or propagated information.
3. NPCs remember at least three prior player actions in later scenes.
4. At least one quest thread can resolve in multiple factionally meaningful ways.
5. At least one rumor spreads from a site back into the hub.
6. The player can learn a technique and gain proficiency by using or training it.
7. At mastery, the player can evolve a technique using a chosen reference and their history.
8. The player can attempt one shrine breakthrough that changes their base path.
9. Scenario tests can replay the happy path and rebuild derived state from the canonical event log.

## After the PoC

If the story loop works, the next step is a visual client. The meridian package stays the same — a game client connects to the same agents and skills and renders the world visually.

The current V1 direction is turn-based party combat, closer to Darkest Dungeon than an action RPG: readable positions, stress, wounds, status effects, marks, and named techniques.