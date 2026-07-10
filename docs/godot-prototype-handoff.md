# Godot Prototype Handoff

This is the brief for the next implementation agent. Build the deterministic game prototype first. Do not build the LLM game engine in this pass.

## Goal

Create a clean, beautiful, playable Godot prototype of the core Living RPG loop:

1. The player starts in a small authored region.
2. The player can inspect the current situation, move between connected places, talk to characters, and make choices.
3. The world changes deterministically in response to those choices.
4. The UI makes location, options, consequences, and character state clear.
5. The prototype can later accept LLM-authored content through explicit data contracts, but it must be fun and testable without an LLM.

## Current State (updated 2026-07-10)

The first playable deterministic slice is implemented. See `godot/PLAYTEST.md`
for how to run and verify it, and `design/pages/decisions.md` ("Prototype combat
direction") for the combat/spirit decisions it encodes.

What exists now:

- **Sim core ("commands in, events out")** — plain typed RefCounted classes, no scene-tree
  dependency: `game/story/` (GameState, EventLog, ActorState, TechniqueState, SpiritState),
  `game/combat/` (CombatState, Combatant, Damage), `game/shared/rng_service.gd` (seeded RNG).
  Every state change appends a serializable event to one append-only EventLog — this is the
  future LLM contract surface.
- **Turn-based party combat** — speed-ordered turns, per-character qi, stacking statuses
  (vulnerable/burn/guard), enemy break meters via element tags, spirit Bonded/Invoked/Resting
  tri-state, technique use-counters with proficiency thresholds.
- **Authored content as .tres** under `game/data/content/` (areas, NPCs, enemies, techniques,
  spirit, encounters) with typed Resource definition scripts in `game/data/`.
- **Overworld** — walkable placeholder areas (hub + road + ruin + shrine), exits, NPC dialogue
  with flag-branching choices, shrine pact, two-outcome quest (fight or negotiate).
- **Observability** — event-log panel [L], debug overlay [F3], toast errors, headless test
  suite (`godot --headless --path godot -s res://tests/run_tests.gd`, no addon required).

Known gaps / next passes: real art and tiles, save/load, balance, the reactive timing layer
(deferred by decision), and the LLM engine dirs (`agents/`, `tools/`, `world-state/`).

## Product Direction

The prototype should feel like a compact fantasy RPG interface, not a chatbot wrapper. Use authored content freely. Manual design is preferred over procedural breadth.

Build the first version as free-form 2D with 2.5D presentation: top-down movement, authored areas, y-sorted depth, and camera framing that keeps a Hades-like feel possible without committing the project to full 3D.

Good first slice:

- One hub and three to five connected sites.
- Three to five named NPCs.
- One short quest thread with at least two meaningful outcomes.
- One technique or ability that can improve through use.
- One shrine, vow, or breakthrough choice that changes future options.
- A simple conflict/combat resolution model.
- A readable event log or memory panel showing what changed.
- A debug overlay or trace view that exposes current area, player position, active flags, and recent events.

## Architecture Boundary

Godot owns:

- Player input and UI.
- Local deterministic gameplay rules for the prototype.
- Presentation state and animation.
- Authored prototype data needed to play.

Godot should expose or keep separable:

- A view model for the current scene.
- A command/action interface for player choices.
- A serializable event log or trace.
- A debug/inspection surface for current deterministic state.

Future LLM systems may provide scene text, NPC dialogue options, world events, or authored content. They should not be required for basic play.

## Suggested Implementation Shape

Start simple:

```text
godot/game/app/
  main.tscn           main playable screen
  main.gd             top-level UI/world wiring

godot/game/world/
  world.tscn          first authored area container
  world.gd            area loading and world-scene coordination

godot/game/actors/player/
  player.tscn
  player.gd

godot/game/story/
  game_state.gd       deterministic prototype state and rules

godot/game/debug/
  debug_overlay.tscn   optional first debug UI
  trace_log.gd         action/event trace capture when needed
```

Keep `game_state.gd` deeper rather than scattering shallow manager files. Split only when a concept becomes independently large enough to justify it.

Use typed GDScript. Keep scripts small enough for agents to read fully. Prefer more focused folders and local files over broad catch-all files, as long as the split reflects real gameplay concepts rather than boilerplate.

## UI Expectations

The first screen should be the playable game, not a landing page.

Prioritize:

- Clear location and exits.
- Legible narrative/status text.
- Action buttons for expected choices.
- Typed command input only if it improves play.
- Character/status panels that support decision-making.
- A restrained, polished visual language.
- Developer-only debug output that makes state changes inspectable.

Avoid:

- Marketing-style hero sections.
- Decorative card grids.
- Purple gradient defaults.
- Beige parchment defaults unless the whole art direction explicitly earns it.
- Huge text inside dense tool panels.
- Nested cards.

## Verification

Before handing off, run the actual Godot project. At minimum:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --path godot --quit
```

If a runnable prototype exists, also open it locally and play through the happy path:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path godot
```

Report what was verified and what was not.
