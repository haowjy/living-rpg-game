# Godot Scaffold Rationale

The scaffold comes from three inputs:

1. The existing Living RPG design docs, especially the deterministic world-state/tool boundary and first-slice goals.
2. Godot's scene-based project model, where scenes, scripts, resources, and local assets work well when grouped by gameplay concept.
3. This repo's development principles: small complete slices, smaller files, focused folders, minimal abstractions, and no manager sprawl before there is real behavior.

## Chosen Direction

Start as a free-form 2D game with 2.5D presentation:

- `Node2D` world scenes.
- `CharacterBody2D` actors.
- Authored areas rather than procedural breadth.
- Y-sorted depth, z-index, camera framing, and angled/painterly assets for a Hades-like feel.
- No full 3D architecture until 2D/2.5D proves insufficient.

This keeps movement and combat expressive without requiring 3D asset, camera, navigation, and lighting complexity before the core loop exists.

## Folder Reasoning

The project is grouped by gameplay domain, not by file type:

- `game/app` starts and wires the game.
- `game/world` owns areas, exits, terrain, and cameras.
- `game/actors` owns player, NPC, and enemy scenes.
- `game/interaction` owns prompts, interactables, and choice dispatch.
- `game/story` owns deterministic memory, flags, quests, and progression.
- `game/combat` exists for conflict rules once built.
- `game/ui` owns player-facing interface.
- `game/debug` owns overlays, trace capture, and inspection tools.
- `game/data` owns authored content.
- `game/shared` is reserved for small cross-domain primitives only.

Folders should stay focused so an AI agent can read the whole local context before changing it. Empty folders are tracked only where they communicate intended ownership.

## Debugging And Observability

The first playable slice should include observability from the start:

- Debug overlay for current area, player position, active flags, current target, and recent events.
- Structured action/event trace, preferably JSON-compatible, so behavior can be replayed or inspected.
- Clear invalid-action errors instead of silent failure.
- State dump command or debug panel for deterministic gameplay state.

The debug layer should observe and report state, not own state.
