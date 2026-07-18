# Control Architecture

Living RPG gives authored scripts, deterministic AI, players, and LLMs access
to the same validated game commands. No controller may mutate canonical state
or manipulate presentation internals directly.

## Boundary

```text
controllers
  player input | authored script | deterministic AI | LLM adapter
                              |
                              v
                    validated commands
                              |
                              v
                    deterministic state
                              |
                              v
                     canonical events
                       /           \
                      v             v
              presentation      world memory
```

The separation makes each LLM optional at runtime without making LLM direction
an afterthought in the product.

## Three responsibilities

### Deterministic simulation

The simulation decides what is legal and what happened. It owns movement,
time, schedules, inventory, spawning, combat resolution, effects, technique
budgets, weapon budgets, and canonical state.

### LLM direction

LLMs interpret context and propose meaningful choices:

- **Story Oracle:** selects pressure and proposes a scene at defined trigger
  points.
- **Character interaction:** writes or selects dialogue from the character's
  knowledge, memory, goals, and emotional state.
- **Battle controller:** chooses among legal actions. Deterministic AI is the
  fallback.
- **Growth Oracle:** proposes technique evolutions, weapon traits, and reforging
  paths from player-selected references and history.
- **Story-writing adapter:** turns separately produced story material into
  validated scene beats and Director cues.

### Presentation

The presentation performs intent. It owns animation timing, pathfinding,
camera movement, dialogue layout, portraits, sound, transitions, and combat
effects. It observes events but does not invent state changes.

## Two command surfaces

Simulation commands change the world:

```text
move_character
advance_time
transfer_item
record_request
record_commitment
apply_combat_action
record_training
evolve_technique
reforge_weapon
write_event
```

Director commands stage what the player sees:

```text
speak
move_to
face
emote
focus_camera
play_animation
offer_choices
begin_encounter
transition_area
```

A Director command cannot silently create an item, move money, change a
relationship, or deal damage. Those changes require simulation commands.

## LLM request lifecycle

Every LLM lane follows the same envelope:

1. A deterministic trigger requests a proposal.
2. A context builder retrieves only relevant state and memories.
3. The model returns a structured proposal.
4. Schema validation checks its shape.
5. Domain validation checks presence, knowledge, legality, budget, and scope.
6. Accepted commands execute and emit events.
7. Invalid proposals may be repaired once, then fall back deterministically.
8. Inputs, outputs, validation failures, cost, and latency remain inspectable.

## State and retrieval

Canonical state may be stored in structured files or a database, but it must
remain inspectable and independent of model context. An append-only event log
records what happened. Full-text and semantic indexes are rebuildable
projections used to retrieve relevant history; they are never sources of truth.

TypeScript is the current implementation preference. The final client engine,
backend topology, and model providers remain open until the presentation and
Director spike has been evaluated.
