# Living RPG

The Living Story Sandbox RPG. The game is deterministic code and authored data in
`godot/`, playable without an LLM; its design is in `design/`. An LLM engine will
later propose narration, world events and agent behavior through narrow contracts
(commands in, events out), and must never become the only way the game works.

## Rules

- The LLM engine is design work only, with no runtime, until a standalone demo of
  the deterministic game is fun on its own (`design/pages/decisions.md`). Sim work
  must not paint that engine into a corner: keep state changes behind the
  commands-and-events contract. Its V0 contract is
  `design/pages/implementation-spec.md`.
- Keep runtime state and mutation rules deterministic unless a file is explicitly
  part of the LLM experiment.
- Godot code stays in `godot/`; read `godot/AGENTS.md` before working there. Agent
  prompts, tools and world-state files stay out of it.
- `agents/`, `skills/`, `tools/`, `world-state/` and `tests/` are empty on purpose,
  reserved for the LLM engine. Don't fill them speculatively.
- One concept, one owner: no quest state in Godot alongside quest state in
  world-state files without a contract between them.
- Prefer a small working vertical slice over broad scaffolding. Generated UI isn't
  done until it has been opened and playtested.
- Decisions go in `design/pages/decisions.md`, which wins over conflicting design
  pages. Code-local depth goes in `.context/` beside the code.
- Work on the main checkout, one slice at a time; use a worktree only for
  text-heavy or throwaway work, never for scene or asset changes. Why, the asset
  policy and the Godot MCP setup: `docs/godot-workflow.md`.
