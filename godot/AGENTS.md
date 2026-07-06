# Godot Prototype

This directory is a Godot 4.7 project for the deterministic playable prototype. Build the game here first; the LLM engine can connect later through explicit contracts.

## Mental Model

The prototype is a free-form 2D RPG with 2.5D presentation. Start with `Node2D`, `CharacterBody2D`, authored areas, y-sorted depth, and a camera that supports Hades-like arena movement without committing to full 3D.

Godot owns presentation, player input, local gameplay state, authored prototype data, and deterministic rules needed for play. It should not depend on an LLM to run.

## Structure

```text
game/app/          Entry scene, boot flow, top-level wiring
game/world/        Area loading, terrain, exits, cameras, regional scenes
game/actors/       Player, NPCs, enemies, and their local behavior
game/interaction/  Interactables, prompts, dialogue triggers, choice dispatch
game/combat/       Deterministic conflict/combat model when it exists
game/story/        Event log, flags, quests, memory, and progression state
game/ui/           HUD, dialogue, journal, combat UI, menus
game/data/         Authored prototype content and data resources
game/debug/        Debug overlays, trace capture, inspection tools
game/shared/       Small cross-domain primitives only
assets/            Runtime assets committed with the project
addons/            Third-party Godot plugins
tools/             Godot-local editor/dev scripts
```

## Rules

- Prefer one complete vertical slice over broad framework scaffolding.
- Use typed GDScript.
- Keep scripts close to the scenes/resources they serve.
- Prefer smaller files and more focused folders over large catch-all scripts. This project is optimized for AI-assisted development where agents need to read complete local context.
- Do not add global autoloads until there is a concrete cross-scene lifecycle need.
- Do not create manager classes by default. Start with deeper local modules and split when a concept becomes independently large.
- Add observability with the first playable slice: debug overlay, event trace, state inspection, and clear error output.
- Keep branch-owned runtime assets in `assets/`; use ignored `external_assets/` only for local shared asset libraries.
- Keep the first screen playable. Do not build a landing page.

## Anti-Patterns

- Full 3D architecture before 2D/2.5D proves insufficient.
- Tile-locked structure unless a specific mechanic needs it.
- Separate quest/dialogue/combat managers that only forward calls.
- LLM-only gameplay paths.
- Broad scene rewrites without opening and testing the project.
