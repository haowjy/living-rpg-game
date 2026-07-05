# Living Story Sandbox RPG Systems Bundle

This bundle has been updated around the current north star:

**A living fantasy sandbox where the world remembers what the player does, techniques grow through simple proficiency, mastered forms can evolve through player-chosen references, and shrines reshape the player's deeper path.**

## What changed

- The old Greyford-first framing is no longer the public anchor. The first slice still needs a small authored region, but placeholder LLM-generated names should not define the pitch.
- The old event-triggered insight pipeline is replaced. Events are context, not automatic upgrade triggers.
- Training is simple: use a technique, practice it, study a manual, or train with a teacher to raise proficiency.
- Technique evolution happens at proficiency thresholds. The player chooses references — another technique, a manual passage, a strange book, a shrine, a memory, or a written idea — and the LLM reads those references plus history to propose evolutions.
- Shrines, statues, and altars are breakthrough sites. They upgrade the player's base path, element, bonuses, vows/curses, and future weirdness ceiling.
- V1 combat direction has shifted away from real-time action. The target is turn-based party combat, closer to Darkest Dungeon: positions, turns, stress, injuries, marks, status effects, and named techniques.
- The architecture assumes deterministic state plus LLM-assisted narration/proposals, not an LLM acting as the entire game.
- The Minecraft mod path remains rejected. Minecraft is a useful sandbox reference, not the implementation target.
- The information hierarchy should keep player-facing fantasy separate from implementation detail.

## Main pages

- `pages/overview.md` — answer-first overview and north star.
- `pages/story-sandbox.md` — story as the primary attractor.
- `pages/agent-architecture.md` — deterministic runtime and LLM boundary.
- `pages/world-state.md` — canonical files, event log, and searchable projections.
- `pages/implementation-spec.md` — V0 state schemas, tool contracts, validation rules, and scenario tests.
- `pages/story-system.md` — story pressure, sifting, scene generation, and validation.
- `pages/clock-agents.md` — layered world clock and named background agents.
- `pages/quests-threads.md` — quests as living story threads.
- `pages/worldgen-sites.md` — continuous world generation and site meaning.
- `pages/growth-power.md` — technique proficiency, evolution, shrines, and broader power paths.
- `pages/player-character.md` — player stats, skills, techniques, equipment, and progression.
- `pages/prototype.md` — first playable text PoC.
- `pages/decisions.md` — canonical decisions that supersede conflicts elsewhere.
- `pages/research-notes.md` — compact research takeaways.