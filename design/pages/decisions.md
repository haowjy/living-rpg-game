# Session Decisions

Decisions from the design review. These supersede conflicting statements in earlier bundle pages.

## 2026-07-10 — Prototype combat direction (supersedes "Combat direction" below)

Decided while building the first deterministic Godot slice:

- **Turn-based party combat from the start.** The prototype's conflict model is a visual
  turn-based battle screen, not narrative choice resolution. Reference points shifted from
  Darkest Dungeon toward Chained Echoes / Persona / Octopath / Expedition 33.
- **Team play = stacking effects and combos**, Slay-the-Spire-style: statuses are integer
  stacks (vulnerable, burn, guard); the party coordinates by setting up and exploiting
  stacks across members. No shared party gauge. Resource economy is **per-character qi**.
- **Break meters:** enemies have toughness depleted only by matching element/type tags;
  emptying it stuns for a round and adds a damage window (Octopath/E33-style).
- **Spirits (new system):** xianxia-style spirit-beast contracts. A spirit is a party member
  with a Golden-Sun-Djinn-shaped tri-state: **Bonded** (passive buff on its contract holder,
  Invoke available) → **Invoked** (big move) → **Resting** (passive suspended, cooldown).
  Contracts are earned narrative moments with a visible cost (a vow), never collection.
  Small-roster philosophy: few, deeply bonded, authored spirits — not a box.
- **Expedition 33-style reactive timing (parry/dodge) is deferred.** When added, it must be a
  pure timing-quality multiplier layered on the deterministic core, with an auto-resolve
  accessibility toggle shipped in the same commit (Hi-Fi Rush pattern).
- **Technique proficiency in combat:** techniques track use counters; thresholds raise power
  and cut qi cost. Proficiency changes are combat events in the log.

## Setting

Medieval fantasy with strange power progression. The world is grounded medieval — kingdoms, guilds, churches, trade routes, bandits, ruins, shrines — but power can become mythic and personal over time.

Do not over-center cultivation as the identity of the game. Manuals, training, breakthroughs, and shrine paths can borrow cultivation-like structure, but the player-facing frame is technique mastery and shrine breakthroughs.

## Architecture

The game engine is an LLM agent loop over a structured file system.

The LLM reads world state from files, writes narration as free text, and calls tools when state needs to change. The architecture is: files, an index, tools, and a loop.

The LLM's primary output is prose, not JSON. Structured output is only used for state mutations via tool calls. JSON mode / constrained decoding handles format validity when structured output is needed.

## PoC form factor

The PoC is a meridian package — a set of agents and skills, not a custom Python application. It targets multiple platforms via model policies. The default play experience runs on open platforms.

Agents and skills map from the creative-writing-skills pattern:

| Creative writing | Game engine |
|---|---|
| Muse | Game director |
| Writer | Narrator |
| Critic | Validator |
| Character-sim | NPC agents |
| KB | World state |
| Story memory | Event log |
| Vocab / shared-dao | World lore, canonical terms |

## Player character

Use familiar RPG stats: STR, DEX, CON, INT, WIS, CHA, HP, and level. Equipment slots and use-based skills are fine. Familiarity is a strength.

Techniques are learned forms with proficiency. The player can later evolve mastered techniques using references and history.

## Combat direction

> **Superseded** by "2026-07-10 — Prototype combat direction" above: visual
> turn-based party combat from the start, stacking statuses, break tags,
> spirits. Kept for the reasoning trail.

**V0:** Narrative turn resolution. The player describes what they do in free text. The LLM interprets and narrates the outcome, while tools validate state changes.

**V1:** Turn-based party combat, closer to Darkest Dungeon than an action RPG. Use positions, turn order, stress, injury, marks, status effects, target rules, named techniques, retreats, and party state.

The deterministic combat layer handles turns, damage, legal targets, status effects, proficiency gain, and cooldowns. The LLM handles barks, contextual complications, morale, enemy recognition, post-combat consequences, and technique evolution proposals.

Real-time action combat is no longer the default target.

## Story sifting

LLM-driven, not rigidly rule-based. The sifter reads the event stream and proposes emerging patterns as story threads. The runtime validates that proposed threads reference real events and characters. Timing is flexible.

## Technique mastery

The core differentiator is not automatic event-to-spell insight generation.

The actual model:

1. **Learn** — acquire techniques from manuals, teachers, enemies, relics, shrines, or experiments.
2. **Practice** — proficiency rises through use, drills, study, and training.
3. **Master** — high proficiency unlocks the ability to alter the form.
4. **Evolve** — the player chooses references: another technique, manual passage, strange book, shrine, memory, or written idea.
5. **Validate** — the LLM proposes evolved forms; tools compile the chosen result into legal mechanics.

Events matter because they are context read during evolution, not because they automatically generate insight rewards.

## Shrine breakthroughs

Shrines, statues, and altars are for path-level changes. A breakthrough can affect base level, element, passive bonuses, vows, curses, technique budgets, and the ceiling for how strange later evolutions can become.

This should lean more into prayer / shrine interaction than generic cultivation terminology.

## Dead paths

- **Minecraft mod path:** Killed. Minecraft remains a useful sandbox reference, not the implementation target.
- **Card deck builder:** Killed. A deck builder is a second game that competes with the story for attention.
- **Real-time action RPG as default:** Replaced by turn-based party combat as the more plausible visual target.
- **Cultivation as identity:** Revised. Keep manuals, breakthroughs, and rank-like progression where useful, but do not pitch the game as pure cultivation.
- **Greyford as public anchor:** Rejected. The first region needs authored identity; do not anchor the site on generic LLM-generated names.
- **Automatic insight rewards:** Rejected. Events are context; training and evolution are player-driven.

## LLM failure handling

JSON validity is handled by constrained decoding when structured output is needed. Semantic failures are caught by tool-level validation. Retry once on failure, then graceful degradation with a template appropriate to the scene type.

## World arc

The world starts as a functioning medieval society — multiple kingdoms, trade, guilds, churches. Political tensions exist but things work. Chaos escalates over time as small wars break out and destabilize the region.

Behind the escalation is the Demon King: a human-made existential threat, more plague than dark lord, that grows in power alongside the player. The Demon King's origin is a late-game reveal that recontextualizes the early game.

## Version roadmap

- **V0:** Agents + skills on open agent runtimes with a small deterministic tool layer. Narrative turns, terminal play, canonical file-backed state, validated mutations, technique proficiency, evolution proposals, shrine breakthroughs, and scenario tests.
- **V1:** Visual 2.5D turn-based RPG. Tile exploration, party combat, technique UI, shrine UI, procedurally generated tile environments driven by world state. Same agent backend.

## Art direction

Tile-based procedural exploration, three-quarter perspective, anime-inspired pixel art, 32x32 tiles. Distant terrain is parallax-scrolling painted background, not tiles.

Combat presentation can use side-view or staged party layouts like Darkest Dungeon: readable character poses, positions, status icons, and technique effects over twitch input.

## World generation

Chunk-based, Minecraft-style. A world seed generates a master map: biomes, elevation, roads/rivers, pinned locations. Chunks generate on approach and lock permanently. Chunks are composed from hand-designed prefab templates, not built tile-by-tile from noise. After a chunk locks, the LLM writes the semantic layer: who's here, what happened, what pressure exists. The tiles are set by the generator; the meaning is set by the LLM.

## Open questions

- **Rumor propagation:** Basic explicit tool exists, but richer propagation can evolve later.
- **Economy / resources:** Undefined. Design when the agent loop is running and the gap becomes felt.
- **Save / load:** With file-system state, this may just be copying the folder. TBD.
- **Combat layout:** Decide whether V1 combat uses side-view ranks, grid lanes, or a hybrid staged layout.