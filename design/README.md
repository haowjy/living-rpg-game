# Living Story Sandbox RPG Systems Bundle

This bundle has been updated around the new north star:

**A living fantasy sandbox where story is the primary attraction: start as nobody in a collapsing world, gather people, build power, and turn chaos into your legend.**

## What changed

- The old top-level center of gravity has been replaced. Monster flesh, mutation, and cultivation-style systems are now optional power-path material, not the marketing pitch.
- The primary inspiration is now Minecraft-like sandbox structure: survive, explore, gather, build, and set your own goals.
- Echoes of Mystralia has been added as the spellcrafting reference: the useful takeaway is “make your own spells,” extended here into insight-driven spell creation from the player’s run history.
- “Building” is reframed as party building, faction building, territory building, and eventually kingdom/legend building.
- The first PoC is now a terminal-playable agent package with a small deterministic tool layer, canonical event log, story sifter, and validated local story generation.
- The architecture assumes deterministic state plus LLM-assisted narration/proposals, not an LLM acting as the entire game.
- The Minecraft mod path has been rejected. Minecraft remains a useful sandbox reference, not an implementation target.
- The V0 build contract is captured in `pages/implementation-spec.md`: canonical state schemas, tool contracts, pressure scoring, spellcraft budgets, and the Greyford happy path.
- The information hierarchy has been updated so pages lead with conclusions and push depth into later sections or collapsible details.

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
- `pages/growth-power.md` — personal, social, factional, territorial power, and insight-driven spellcrafting.
- `pages/player-character.md` — player stats, skills, equipment, and progression.
- `pages/prototype.md` — first playable text PoC.
- `pages/decisions.md` — canonical decisions that supersede conflicts elsewhere.
- `pages/research-notes.md` — compact research takeaways.
