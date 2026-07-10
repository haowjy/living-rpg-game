# Godot Game — Contracts & Architecture

Reference depth for `godot/`. Read [`../AGENTS.md`](../AGENTS.md) first.

## Contracts

**Commands in, events out.** The sim exposes exactly three things:

1. A serializable view of current state (view model) that presentation reads.
2. Typed commands, validated before execution. Illegal commands are rejected
   with a reason — `{ok: false, error: "..."}` — never a crash. Rejections
   are themselves logged events.
3. An append-only **event log**: plain dictionaries, JSONL-serializable,
   recording every state change. This is the world's memory and the future
   LLM engine's read surface.

Invariants (tests enforce the first two):

- Same seed + same command sequence ⇒ byte-identical event log (assumes the
  same build and content — the general form is same initial state + same
  inputs + same code/data).
- Every state mutation goes through a command; no presentation writes.
- Event log entries stay plain dictionaries — never Resources. The outward
  contract must be trivially serializable and carry no code-execution
  surface.

## Architecture

| Piece | Role |
|---|---|
| `game/shared/rng_service.gd` | Seeded RNG; all sim randomness flows here. Seed logged in `run_started` and shown in the debug overlay. |
| `game/story/game_state.gd` | Sim of record: overworld commands, flags, party, owns the event log |
| `game/story/event_log.gd` | Append-only event store |
| `game/story/actor_state.gd` | Persistent party-member state (techniques, spirits) |
| `game/combat/combat_state.gd` | Battle sim: turn queue, commands, events |
| `game/combat/combatant.gd` | Battle wrapper — party members write back, enemies stay local |
| `game/combat/damage.gd` | Pure integer damage/status/break math |

Dependency direction: presentation → sim, never the reverse. Sim classes are
engine-agnostic apart from being GDScript; they must run headless with zero
scene instantiation.

## Rationale

- **RefCounted sim, not Nodes**: supported by Godot's official "node
  alternatives" guidance; an idiomatic pattern for data-driven projects
  (not a canonical standard), and it makes the sim unit-testable headless.
- **`.tres` for authored content, dictionaries for events**: content wants
  typed editor authoring and git-diffable text; the event log wants zero
  trust surface. Resource loading is only a security concern for untrusted
  files — fine for developer-authored content; revisit if user content or
  save sharing appears.
- **Zero-dependency test runner over GUT**: the sim needs only assertions;
  GUT's ~200 files weren't worth vendoring. Its `godot_4_7` branch is the
  pick if scene-testing needs grow.
- **Integer math over floats**: Godot physics is documented
  non-deterministic, and float determinism is fragile across
  platforms/compilers. Floats can be deterministic under controlled
  conditions; integers remove the risk instead of managing it.

## Patterns

- New sim rule ⇒ new checks in `tests/` in the same change; the suite covers
  turn order, status/break math, spirit tri-state, proficiency thresholds,
  command validation, and log determinism.
- Content lives as `.tres` under `game/data/content/` with typed definition
  scripts in `game/data/`; look up through `content_db.gd`.
- Run headless before committing:
  `godot --headless --path godot -s res://tests/run_tests.gd` (exits 0 green).
