# Prototype

The proof-of-concept is a meridian package with a small deterministic tool layer. It proves persistent, local, escalating story in a small sandbox. After 30-60 minutes of play, the player should be able to tell a specific story that only happened because of their choices.

## Goal

The prototype is successful if Greyford feels like a place with memory: NPCs react to prior events, rumors move through the world, factions respond to the player's actions, quests branch based on choices, and the player's rise begins to leave marks.

## What to Build

The PoC is a meridian package containing:

| Component | Description |
|---|---|
| Game director agent | The main loop — reads world state, observes pressure, dispatches to other agents |
| Narrator agent | Generates prose from world state and scene context |
| Validator agent | Checks consistency — presence, knowledge, rules, causality |
| NPC agents | One per named character, using the character-sim pattern |
| World state files | The structured directory of prose and data files |
| Tool definitions | `move_character`, `write_event`, `change_relationship`, `spread_rumor`, `claim_site`, `create_quest_thread` |
| Setup skill | Instructions for configuring local models as an alternative backend |

The build contract for these files and tools lives in [V0 Implementation Spec](implementation-spec.md).

## Vertical Slice

| Element | First version |
|---|---|
| Map | Greyford + 6-8 connected sites |
| Characters | Player + 5 named agents + lightweight NPCs |
| Factions | Lordship, Church, Guild, Bandits, Villagers |
| Story threads | North Mill, rival adventurer, Church suspicion, bandit recruitment |
| World clock | Daily regional tick, hourly local tick, wait/travel triggers |
| Memory | Event log, area files, FTS + vector index |

## Player Interaction

The player interacts through natural language. Core actions:

- **look** — Describe the current area, exits, and present characters.
- **move** — Travel to an adjacent area.
- **talk** — Speak to a present character.
- **wait** — Advance the clock and trigger background actions.
- **inspect** — Examine something in detail.
- **take job** — Accept a quest or task.

Example session:

```
Day 1, Hour 9 — Greyford Market

Refugees crowd the market stalls. Lord Vael's soldiers are posting new
road tariffs. At the Guild table, Mara is arguing with a miller whose
hands are still dusted white with flour.

Exits: north Church Hospital · east East Gate
       west Adventurers Guild · south Old Wall Slums
Present: Mara, Tomas, Old Miller Renn

> talk to the miller
```

## Success Criteria

1. The player always knows where they are and what exits/options exist.
2. Generated scenes only use reachable locations, present characters, or propagated information.
3. NPCs remember at least three prior player actions in later scenes.
4. At least one quest thread can resolve in multiple factionally meaningful ways.
5. At least one rumor spreads from a site back into town.
6. The player can begin building a party or power base.
7. Scenario tests can replay the Greyford happy path and rebuild derived state from the canonical event log.

## After the PoC

If the story loop works, the next step is a visual client. The meridian package stays the same — a game client (Godot, web, or other) connects to the same agents and skills and renders the world visually. The text PoC proves the engine; the client provides the body.
