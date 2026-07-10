# Living RPG

This repo is the Living Story Sandbox RPG: the game itself (`godot/`), the
design corpus for the game and its LLM-assisted world simulation, and the
future agent/tool/world-state layers that simulation will need.

## Mental Model

There are two engines here:

- The **gameplay engine** is deterministic code and authored data — the game,
  playable without an LLM. It lives in `godot/` and grows slice by slice.
- The **LLM engine** is a future layer that proposes narration, world events,
  and agent behavior through narrow contracts ("commands in, events out"). It
  must not become the only way the game works.

## Key Rules

- Prefer a small working vertical slice over broad scaffolding.
- Keep runtime state and mutation rules deterministic unless a file is
  explicitly part of the LLM experiment.
- Keep Godot client code inside `godot/` — read `godot/AGENTS.md` before
  working there.
- Keep agent prompts, tools, world-state files, and scenario tests outside
  `godot/` unless there is a concrete integration reason.
- Prefer smaller files and more focused folders. Agents should be able to
  read the complete local context for the thing they are changing.
- Treat worktrees as optional. Use one main checkout for scene and asset
  integration; use worktrees mostly for isolated text/code tasks.
- Do not add dependencies, abstractions, or wrappers before they remove real
  complexity.

## Current Layout

```text
agents/         Future agent definitions and prompts
tools/          Future deterministic mutation and validation tools
world-state/    Future canonical world files and templates
tests/          Future scenario and engine tests
design/         Design source of truth (decisions.md is the log of record)
godot/          The game: Godot 4.7 client + deterministic sim
docs/           Workflow and implementation guidance for agents
```

## Knowledge Layers

- `AGENTS.md` frames a directory; `.context/CONTEXT.md` beside it holds
  code-local contracts, architecture, and rationale (start:
  `godot/.context/CONTEXT.md`).
- Cross-cutting design knowledge — system pages, decision records,
  vocabulary — lives in the project KB (meridian-managed; `meridian context`
  shows the path). Repo files stay the source of truth for build contracts;
  the KB synthesizes and indexes.

## Anti-Patterns

- Building the LLM runtime before the deterministic game loop is solid.
- Letting Godot scenes become the only source of gameplay rules.
- Adding parallel systems for the same concept, such as separate quest state
  in Godot and world-state files with no contract between them.
- Making every AI task use a full asset worktree.
- Treating generated UI as finished without opening and playtesting it.

## Read Next

- `godot/AGENTS.md` — how to work in the game.
- `docs/ai-dev-workflow.md` — branch/worktree rules, verification, Godot MCP.
- `design/pages/decisions.md` — decision log of record.
- `design/pages/implementation-spec.md` — the V0 LLM-engine contract.
