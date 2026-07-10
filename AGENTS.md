# Living RPG

The Living Story Sandbox RPG: the game in `godot/`, its design in `design/`,
and a future LLM world-simulation layer connected through narrow contracts.

## Mental Model

Two engines:

- **Gameplay engine** — deterministic code + authored data (`godot/`).
  Playable without an LLM.
- **LLM engine** — future layer proposing narration, world events, and agent
  behavior through narrow contracts ("commands in, events out"). It must not
  become the only way the game works.

## Rules

- Load `/dev-principles` before planning or changing code; `/dev-workflow`
  governs commit cadence.
- Prefer a small working vertical slice over broad scaffolding.
- Keep runtime state and mutation rules deterministic unless a file is
  explicitly part of the LLM experiment.
- Godot code stays in `godot/` — read `godot/AGENTS.md` before working
  there. Agent prompts, tools, and world-state files stay out of it.
- `agents/`, `tools/`, `world-state/`, and `tests/` are intentionally
  empty — reserved for the LLM engine. Don't fill them speculatively.
- Record decisions in `design/pages/decisions.md` (the log of record). Load
  `/knowledge-layers` for where other knowledge goes; code-local depth lives
  in `.context/` (start: `godot/.context/CONTEXT.md`).

## Anti-Patterns

- Building the LLM runtime before the deterministic game loop is solid.
- Letting Godot scenes become the only source of gameplay rules.
- Adding parallel systems for the same concept, such as separate quest state
  in Godot and world-state files with no contract between them.
- Making every AI task use a full asset worktree.
- Treating generated UI as finished without opening and playtesting it.

## Read Next

- `godot/AGENTS.md` — how to work in the game.
- `docs/godot-workflow.md` — worktrees vs binary scenes, asset policy, Godot MCP.
- `design/pages/implementation-spec.md` — the V0 LLM-engine contract.
