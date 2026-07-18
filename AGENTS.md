# Living RPG

The Living Story Sandbox RPG: a presentation-first game designed for LLM
direction through narrow contracts. The current prototype lives in `godot/`;
current product direction and implementation contracts live in `design/`.

## Mental Model

Two engines:

- **Deterministic engine** — establishes legal actions and canonical truth:
  movement, time, combat, items, spawning, save/load, and events.
- **LLM directors** — propose meaningful scenes, dialogue, decisions, and
  upgrades through validated contracts. Every LLM lane needs a deterministic
  fallback.
- **Presentation** — performs accepted commands through movement, animation,
  camera, dialogue, UI, and sound. It never owns gameplay truth.

The shared boundary is **commands in, events out**. LLMs direct intent, not
per-frame physics or unvalidated state changes.

## Rules

- Load `/dev-principles` before planning or changing code; `/dev-workflow`
  governs commit cadence.
- Prefer a small working vertical slice over broad scaffolding.
- Keep runtime state and mutation rules deterministic. LLM output remains a
  proposal until validated commands execute.
- Godot code stays in `godot/` — read `godot/AGENTS.md` before working
  there. Agent prompts, tools, and world-state files stay out of it.
- `agents/`, `tools/`, `world-state/`, and `tests/` are intentionally empty.
  Don't fill them before the implementation direction settles.
- Record decisions in `design/pages/decisions.md` (the log of record). Load
  `/knowledge-layers` for where other knowledge goes; code-local depth lives
  in `.context/` (start: `godot/.context/CONTEXT.md`).

## Anti-Patterns

- Building a complete Oracle before the presentation and Director contract
  prove controllable.
- Treating the game as a chatbot with RPG state.
- Giving an LLM direct access to physics, animation internals, or canonical
  mutation.
- Letting Godot scenes become the only source of gameplay rules.
- Adding a conventional quest checklist beside the request, commitment, and
  living-thread model.
- Making every AI task use a full asset worktree.
- Treating generated UI as finished without opening and playtesting it.

## Read Next

- `godot/AGENTS.md` — how to work in the game.
- `docs/godot-workflow.md` — worktrees vs binary scenes, asset policy, Godot MCP.
- `design/README.md` — current design map.
- `design/pages/implementation-spec.md` — first-slice contracts.
