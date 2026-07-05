# Session Decisions

Decisions from the design review and grilling session. These supersede conflicting statements in earlier bundle pages.

## Setting

Xianxia-like medieval fantasy. The world is grounded medieval (kingdoms, guilds, churches, trade routes) but the progression system is cultivation-inspired. Mana ranks, tiered breakthroughs, and manuals exist alongside swords and politics. Think wuxia energy in a western fantasy shell — the setting is familiar, but power growth follows cultivation logic.

## Architecture

The game engine is an LLM agent loop over a structured file system.

The LLM reads world state from files, writes narration as free text, and calls tools when state needs to change. There is no rigid multi-module pipeline. The architecture page's ten named modules (MapEngine, LocationTracker, StorySifter, StoryDirector, Narrator, Validator, ContentCompiler, etc.) are replaced by: files, an index, tools, and a loop.

The LLM's primary output is prose, not JSON. Structured output is only used for state mutations via tool calls. JSON mode / constrained decoding handles format validity when structured output is needed.

## PoC form factor

The PoC is a meridian package — a set of agents and skills, not a custom Python application. It targets multiple platforms (opencode, Claude, etc.) via model policies. The default play experience runs on open platforms.

Agents and skills map from the creative-writing-skills pattern:

| Creative writing | Game engine |
|---|---|
| Muse (session lead, stance switching) | Game director (loop, observe, dispatch) |
| Writer (prose from briefs) | Narrator (prose from world state) |
| Critic (adversarial reading) | Validator (consistency checking) |
| Character-sim (in-character conversation) | NPC agents (interactive characters) |
| KB (durable story memory) | World state (characters, factions, locations) |
| Story memory (fact extraction) | Event log (what happened) |
| Vocab / shared-dao | World lore, canonical terms |

A setup skill provides instructions for configuring local models (Ollama / llama.cpp) as an alternative backend. The same agents and skills work regardless of backend.

## Player character

Standard RPG stats: STR, DEX, CON, INT, WIS, CHA, HP, level. Equipment slots, skill list that grows from use. Techniques from insights slot into the ability list alongside conventional skills. Don't try to be inventive with the stat model — familiarity is a strength.

## Conflict resolution

**PoC (V0):** Narrative DM. The player describes what they do in free text. The LLM interprets and narrates the outcome.

**V1:** Real-time action combat. The deterministic game engine handles movement, collision, damage, and enemy AI behavior trees. Techniques from insight spellcraft slot into a 4-slot hotbar (number keys / face buttons) usable in real-time. The LLM perturbs fights in the background — enemy dialogue, reinforcements, environmental shifts, morale breaks. The player controls the action; the LLM makes it feel alive. Reference: Echoes of Mystralia for spell-crafting action RPG feel.

## Story sifting

LLM-driven, not rule-based. The sifter reads the event stream and proposes emerging patterns as story threads. The runtime validates that proposed threads reference real events and characters. No rigid pattern-matching rules. Timing is flexible.

## Insight spellcraft and cultivation progression

The core differentiator: "make your own spells from the story you lived." Insight sources are twofold:

1. **Lived experience** — events with narrative weight become insights (as before)
2. **Manuals** — discoverable texts (martial arts manuals, technique scrolls, meditation guides) that the player can study as insight sources

Players can also write their own insights in free text, combining what they learned from manuals with what they experienced in the game.

Insights feed into technique advancement AND mana rank progression. Mana rank is tiered with breakthroughs — accumulate enough insights and pass a challenge/trial to break through to the next tier. Techniques grow stronger as mana rank increases.

This replaces the generic RPG level system. Stats remain (STR, DEX, etc.) but progression is driven by cultivation rank, not XP-based leveling.

## Dead paths

- **Minecraft mod path:** Killed. Turn-based or real-time-with-LLM-perturbation combat is incompatible with Minecraft's mob system. The game needs its own combat, which means Minecraft's sandbox body is more hindrance than help.
- **Card deck builder:** Killed. A deck builder is a second game that competes with the story for attention. The story is the documented north star.
- **Cultivation as identity:** Revised. Cultivation is the core progression mechanic (mana ranks, breakthroughs, manuals). The setting is xianxia-like medieval fantasy, not pure xianxia — the world is grounded medieval, but power growth follows cultivation logic.

## LLM failure handling

JSON validity is handled by constrained decoding (JSON mode). Semantic failures (invalid references, impossible actions) are caught by tool-level validation — if `move_character` requires a valid adjacent location, the tool rejects the call. Retry once on failure, then graceful degradation (template fallback appropriate to scene type).

## World arc

The world starts as a functioning medieval society — multiple kingdoms, trade, guilds, churches. Political tensions exist but things work. The chaos escalates over time as small wars break out and destabilize the region. Behind the escalation is the Demon King — a human-made existential threat, more plague than dark lord, that grows in power alongside the player. The Demon King's origin is a late-game reveal that recontextualizes the early game.

## Version roadmap

- **V0:** Agents + skills on opencode with a small deterministic tool layer. Narrative DM, terminal play, canonical file-backed state, validated mutations, and scenario tests. Proves the agent loop and story systems.
- **V1:** Full 2.5D tile-based game (Godot). Real-time action combat, technique hotbar, procedurally generated tile environments driven by LLM world state. Same agent backend.

## Art direction (V1)

Tile-based procedural rendering, three-quarter perspective, anime-inspired pixel art, 32x32 tiles. Reference: CrossCode, Eastward, Echoes of Mystralia. Distant terrain (mountains, sky) is parallax-scrolling painted background, not tiles.

## World generation (V1)

Chunk-based, Minecraft-style. A world seed generates a master map (biomes, elevation, roads/rivers, pinned locations). Chunks (32x32 or 64x64 tiles) generate on approach and lock permanently. Chunks are composed from hand-designed prefab templates (50-100 authored by an artist), not built tile-by-tile from noise. Prefabs solve elevation — a "hill with watchtower" prefab already knows how to use cliff-face tiles, plateaus, and paths. After a chunk locks, the LLM writes the semantic layer (who's here, what happened, what pressure exists). The tiles are set by the generator; the meaning is set by the LLM.

## Open questions

- **Rumor propagation:** No explicit mechanism designed. May emerge naturally from the agent loop.
- **Economy / resources:** Undefined. Will design when the agent loop is running and the gap becomes felt.
- **Save / load:** With file-system state, this may just be "copy the folder." TBD.
