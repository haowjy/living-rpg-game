# The Game (Godot Client)

This directory is the game: a Godot 4.7 project containing the deterministic
sim and its presentation. The LLM engine connects later through explicit
contracts; nothing here may depend on it.

## Mental Model

Two layers, one boundary:

- **Sim** (`game/story/`, `game/combat/`, `game/shared/`, `game/data/` defs):
  plain typed-GDScript `RefCounted` classes. No Node inheritance, no
  scene-tree access, no `_process`. Owns all gameplay state and rules.
- **Presentation** (scenes, `game/ui/`, `game/world/`, `game/actors/`):
  observes sim state and dispatches typed commands. Never mutates state
  directly.

The contract surface is **commands in, events out**: commands validate before
executing and return `{ok, error}`; every change lands in the append-only
event log. UI, tests, replays — and later the LLM — are all just drivers of
the same surface. Details: [`.context/CONTEXT.md`](.context/CONTEXT.md).

Presentation is free-form 2D with 2.5D staging: `Node2D`, `CharacterBody2D`,
authored areas, y-sorted depth.

## Structure

```text
game/app/          Entry scene, boot flow, top-level wiring
game/world/        Area loading, exits, cameras
game/actors/       Player, NPCs, enemies — presentation-side behavior
game/interaction/  Interactables, prompts, dialogue triggers
game/combat/       Battle sim: state, combatants, damage math
game/story/        Sim of record: game state, event log, actor/spirit state
game/ui/           HUD, dialogue, party, event log panels
game/data/         Typed content defs + authored .tres under data/content/
game/debug/        Debug overlay, state inspection
game/shared/       Cross-domain sim primitives (seeded RNG service)
tests/             Headless sim test suite (zero-dependency runner)
assets/            Runtime assets committed with the project
addons/godot_ai/   Editor MCP bridge — dev tooling only, never a runtime
                   channel for the LLM engine
```

## Rules

- **Determinism**: integer math in sim code (floats are presentation-only);
  all sim randomness flows through the one seeded RNG service; no
  `Time`/physics reads in sim code. Same seed + same commands must produce
  an identical event log — a test enforces this.
- Keep the headless suite green and extend it with every new sim rule:
  ```bash
  godot --headless --path godot --quit                      # boots clean
  godot --headless --path godot -s res://tests/run_tests.gd # suite green
  ```
- Use typed GDScript. Commit editor-generated `.uid` files with their scripts.
- Prefer one complete vertical slice over broad framework scaffolding.
- Prefer smaller files and focused folders; keep scripts close to what they
  serve. No global autoloads or manager classes until a concrete need exists.
- Do not bulk-edit scenes, resources, or assets without a focused task —
  binary and scene churn is hard to review.
- Keep branch-owned runtime assets in `assets/`; ignored `external_assets/`
  is only for local shared asset libraries.
- Keep the first screen playable. No landing page.

## Anti-Patterns

- Sim code reading the scene tree, wall clock, or unseeded randomness.
- LLM-only gameplay paths.
- Full 3D architecture before 2D/2.5D proves insufficient.
- Separate quest/dialogue/combat managers that only forward calls.
- Broad scene rewrites without opening and playtesting the project
  (`PLAYTEST.md` is the manual checklist).

## Read Next

- [`.context/CONTEXT.md`](.context/CONTEXT.md) — contracts, architecture,
  rationale.
- [`PLAYTEST.md`](PLAYTEST.md) — boot/test commands and the manual checklist.
