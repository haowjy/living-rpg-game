# The Game (Godot Client)

A Godot 4.7 project holding the deterministic sim and its presentation. Nothing here
may depend on the LLM engine. Contracts, architecture and rationale:
[.context/CONTEXT.md](.context/CONTEXT.md). Boot and test commands, and the manual
playtest checklist: [PLAYTEST.md](PLAYTEST.md).

## Two layers, one boundary

- **Sim** (`game/story/`, `game/combat/`, `game/shared/`, the defs in `game/data/`):
  plain typed-GDScript `RefCounted` classes. No Node inheritance, no scene-tree
  access, no `_process`. Owns all gameplay state and rules.
- **Presentation** (scenes, `game/ui/`, `game/world/`, `game/actors/`): reads sim
  state and dispatches typed commands. Never mutates state directly.

Commands validate before executing and return `{ok, error}`; every change lands in
the append-only event log. UI, tests, replays and later the LLM all drive that one
surface.

## Rules

- **Determinism.** Integer math in sim code (floats are presentation-only); all sim
  randomness goes through the seeded RNG service (`game/shared/rng_service.gd`); no
  `Time` or physics reads in sim code. Same seed and same commands must produce an
  identical event log; a test enforces it.
- Extend the headless suite (`tests/`) with every new sim rule and run it before
  committing.
- Use typed GDScript. Commit editor-generated `.uid` files with their scripts.
- Keep scripts beside the scenes and resources they serve. No autoloads, and no
  manager classes that only forward calls, until a concrete need exists; the one
  autoload, `_mcp_game_helper`, belongs to the Godot AI addon.
- `addons/godot_ai/` is editor tooling only, never a runtime channel for the LLM
  engine.
- Don't bulk-edit scenes, resources or assets without a focused task: binary and
  scene churn is hard to review. Open and playtest the project after any scene
  rewrite.
- Branch-owned runtime assets go in `assets/`; the ignored `external_assets/` is
  only for local shared asset libraries.
- Presentation is 2D with 2.5D staging (`Node2D`, `CharacterBody2D`, y-sorted
  depth); don't build 3D architecture before 2D proves insufficient.
- The first screen is playable: no landing page.
