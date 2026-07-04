# Living RPG Engine

Game engine for **Living Story Sandbox RPG** — an LLM agent loop that runs a fantasy world.

See the [project site](https://haowjy.github.io/living-rpg-public/) and [design docs](https://github.com/haowjy/living-rpg-public/tree/main/design) for full context.

## Architecture

The engine is a set of specialized agents orchestrated by a game director. Each agent reads world state from files, performs its role, and writes mutations back.

```
game-director          Orchestrates turns, routes to sub-agents
├── narrator           Prose generation from world state + player action
├── validator          Checks proposed state changes for consistency
├── npc-agent          Drives NPC behavior, dialogue, goals
├── world-ticker       Advances clocks, weather, NPC schedules
└── insight-engine     Tracks player experiences → insight → spell proposals
```

## Repo layout

```
agents/         Agent definitions (system prompts, tool configs)
tools/          MCP tools for world-state mutation (move, talk, trade, combat, etc.)
world-state/    Runtime world files (chunks, NPCs, player, clocks)
  templates/    Prefab templates for worldgen (tavern, shrine, bandit camp, etc.)
skills/         Claude Code skills for gameplay modes
tests/          Scenario tests (replay a session, check state consistency)
```

## V0 target

Terminal-based play via Claude Code. Greyford (starting town) + 6-8 sites, 5 named NPCs, core tools, playable in 30-60 min.

## Related repos

- [living-rpg-public](https://github.com/haowjy/living-rpg-public) — project site + design docs
- [creative-writing-skills](https://github.com/haowjy/creative-writing-skills) — narrative agent foundation
- [meridian-prompter](https://github.com/haowjy/meridian-prompter) — prompt engineering toolkit
