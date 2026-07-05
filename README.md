# Living RPG Engine

Game engine for **Living Story Sandbox RPG** — an LLM-assisted fantasy sandbox with file-backed world state, deterministic tools, technique mastery, shrine breakthroughs, and turn-based RPG combat.

See the [project site](https://haowjy.github.io/living-rpg-public/) and [design docs](design/) for full context.

## Architecture

The engine is a set of specialized agents orchestrated by a game director. Agents read world state from files and propose actions; deterministic tools validate and write canonical mutations.

```text
game-director          Orchestrates turns, routes to sub-agents
├── narrator           Prose generation from world state + player action
├── validator          Checks proposed state changes for consistency
├── npc-agent          Drives NPC behavior, dialogue, goals
├── world-ticker       Advances clocks, weather, NPC schedules
└── technique-engine   Tracks learned forms, proficiency, evolution, breakthroughs
```

## Repo layout

```text
agents/         Agent definitions (system prompts, tool configs)
tools/          Tools for validated world-state mutation and projection rebuilds
world-state/    Runtime world files (chunks, NPCs, player, clocks)
  templates/    Prefab templates for worldgen (shrine, road, ruin, camp, etc.)
skills/         Claude Code skills for gameplay modes
tests/          Scenario tests (replay a session, check state consistency)
```

## V0 target

Terminal-based play via opencode/Claude Code. The first slice is a small authored starting region with a safe hub, several connected sites, 5 named NPCs, at least one manual/teacher, one shrine breakthrough, core tools, scenario tests, and 30-60 minutes of playable story.

V0 combat is narrative turn resolution. V1 should move toward visual turn-based party combat — closer to Darkest Dungeon than an action RPG.

## Related repos

- [living-rpg-public](https://github.com/haowjy/living-rpg-public) — project site + design docs
- [creative-writing-skills](https://github.com/haowjy/creative-writing-skills) — narrative agent foundation
- [meridian-prompter](https://github.com/haowjy/meridian-prompter) — prompt engineering toolkit