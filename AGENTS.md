# Living RPG Engine

This repo is a design-first game engine workspace for Living Story Sandbox RPG. It contains the long-term LLM-assisted world simulation design, and now a minimal Godot subproject intended to become a deterministic playable prototype.

## Mental Model

There are two engines here:

- The **gameplay engine** is deterministic code and authored data. It should be playable without an LLM.
- The **LLM engine** is a future layer that proposes narration, world events, and agent behavior through narrow contracts. It must not become the only way the game works.

The Godot prototype should prove the core loop first: exploration, authored scenes, choices, combat or conflict resolution, progression, and readable UI. The LLM layer can be built in parallel later, but it should connect through explicit inputs and outputs rather than reaching into Godot internals.

## Key Rules

- Prefer a small working vertical slice over broad scaffolding.
- Keep runtime state and mutation rules deterministic unless a file is explicitly part of the LLM experiment.
- Keep Godot client code inside `godot/`.
- Keep agent prompts, tools, world-state files, and scenario tests outside Godot unless there is a concrete integration reason.
- Do not bulk-edit Godot scenes, resources, or assets without a focused task. Binary and scene churn is hard to review.
- Use typed GDScript for Godot code unless a stronger reason for C# is documented.
- Prefer smaller files and more focused folders. Agents should be able to read the complete local context for the thing they are changing.
- Treat worktrees as optional. Use one main checkout for scene and asset integration; use worktrees mostly for isolated text/code tasks.
- Do not add dependencies, abstractions, or wrappers before they remove real complexity.

## Current Layout

```text
agents/         Future agent definitions and prompts
tools/          Future deterministic mutation and validation tools
world-state/    Future canonical world files and templates
tests/          Future scenario and engine tests
design/         Current design source of truth
godot/          Minimal Godot 4.7 project scaffold for the deterministic prototype
docs/           Handoff and implementation guidance for agents
```

## Anti-Patterns

- Building the LLM runtime before a deterministic playable loop exists.
- Letting Godot scenes become the only source of gameplay rules.
- Adding parallel systems for the same concept, such as separate quest state in Godot and world-state files with no contract between them.
- Making every AI task use a full asset worktree.
- Treating generated UI as finished without opening and playtesting it.

## Read Next

- `docs/godot-prototype-handoff.md` for the next AI implementation brief.
- `docs/ai-dev-workflow.md` for branch/worktree and verification rules.
- `design/pages/implementation-spec.md` for the older LLM-first V0 contract.
- `design/pages/prototype.md` for the intended first slice of the living RPG.
