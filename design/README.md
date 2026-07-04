# Living Story Sandbox RPG Systems Bundle

This bundle has been updated around the new north star:

**A living fantasy sandbox where story is the primary attraction: start as nobody in a collapsing world, gather people, build power, and turn chaos into your legend.**

## What changed

- The old top-level center of gravity has been replaced. Monster flesh, mutation, and cultivation-style systems are now optional power-path material, not the marketing pitch.
- The primary inspiration is now Minecraft-like sandbox structure: survive, explore, gather, build, and set your own goals.
- Echoes of Mystralia has been added as the spellcrafting reference: the useful takeaway is “make your own spells,” extended here into insight-driven spell creation from the player’s run history.
- “Building” is reframed as party building, faction building, territory building, and eventually kingdom/legend building.
- The first PoC is now a local text/world simulation focused on a map engine, location tracker, event log, story sifter, and validated local story generation.
- A possible post-PoC path has been recorded: the first serious playable version could be a Minecraft mod using Minecraft as the sandbox substrate and the Living World Engine as a portable local backend.
- The architecture assumes deterministic state plus LLM-assisted narration/proposals, not an LLM acting as the entire game.
- The Minecraft path assumes one flexible/data-driven mod, not true runtime generation or hotloading of new Java mods. The LLM builds validated content specs over prebuilt primitives.
- The information hierarchy has been updated so pages lead with conclusions and push depth into later sections or collapsible details.

## Main pages

- `index.html` — answer-first overview and north star.
- `story_sandbox.html` — story as the primary attractor.
- `map_location.html` — map engine and location tracker.
- `data_model.html` — folder + SQLite + FTS + vector data structure.
- `story_system.html` — story sifter/director/narrator/validator system.
- `world_clock_agents.html` — layered world clock and named background agents.
- `quests_threads.html` — quests as living story threads.
- `worldgen_sites.html` — continuous world generation and site meaning.
- `growth_power.html` — personal, social, factional, territorial power, and insight-driven spellcrafting.
- `architecture.html` — deterministic runtime and LLM boundary.
- `local_stack.html` — fully local PoC tech stack.
- `prototype_plan.html` — first playable text PoC.
- `minecraft_mod_path.html` — possible post-PoC path using Minecraft as the sandbox body and a hot-reloadable living-content runtime.
- `research_notes.html` — compact research takeaways.
