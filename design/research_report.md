# Cultivation RPG — Research Report

## 1. LLM World Models & Agent Architectures

### Foundational Papers

**Generative Agents: Interactive Simulacra of Human Behavior** (Park et al., Stanford/Google, UIST 2023, arXiv:2304.03442). 25 LLM-powered agents in "Smallville" with a three-part cognitive architecture: Memory Stream (logs all experiences in natural language), Retrieval (ranks memories by recency, importance, relevance), and Reflection (periodically synthesizes observations into higher-level insights). Agents autonomously plan schedules, form relationships, and coordinate group activities. This is the direct blueprint for your NPC behavior — the memory/reflection/retrieval pattern is the most-cited approach for believable NPCs.

**Voyager** (Wang et al., NVIDIA/Caltech, NeurIPS 2023, arXiv:2305.16291). First LLM-powered lifelong learning agent in Minecraft. Three components: Automatic Curriculum (proposes exploration goals calibrated to agent state), Skill Library (stores executable JavaScript functions indexed by embedding), Iterative Prompting (up to 4 rounds of code refinement using environment feedback). Achieves 3.3x more unique items and 15.3x faster milestone unlocking vs prior methods. Demonstrates how LLM agents can autonomously acquire and compose skills in open-world games.

**SPRING: Studying the Paper and Reasoning to Play Games** (Wu et al., CMU/NVIDIA, NeurIPS 2023, arXiv:2305.15486). The LLM reads the academic paper describing a game, extracts mechanics via QA, then plays using a DAG-based reasoning framework. GPT-4 with SPRING outperforms all RL baselines trained for 1M steps — with zero training. Shows LLMs can learn game rules from documentation, relevant for an RPG with complex systems where the AI needs to "understand the rulebook."

### World Models

**World Models** (Ha & Schmidhuber, NeurIPS 2018, arXiv:1803.10122). Foundational: a VAE compresses frames into latent vectors, an MDN-RNN predicts future states, and a linear controller operates on learned representations. Agents trained inside their own "hallucinated dream" can transfer policies to real environments.

**JEPA** (LeCun, 2022 position paper). Predicting in abstract embedding space rather than pixel/token space. Concrete implementations: I-JEPA (CVPR 2023), V-JEPA/V-JEPA 2 (Meta AI, 2024-2025) pre-trained on 1M+ hours of video.

**Genie / Genie 2 / Genie 3** (Google DeepMind, 2024-2026). Genie 1: 11B-parameter world model trained from unlabeled video, generates playable 2D game environments from a single image (ICML 2024, arXiv:2402.15391). Genie 2 (Dec 2024): extends to 3D. Genie 3 (2025-2026): first real-time interactive general-purpose world model at 24 FPS from text prompts.

**GameNGen** (Google Research/Tel Aviv, ICLR 2025, arXiv:2408.14837). First neural game engine — simulates DOOM at 20+ FPS on a single TPU via diffusion model. Human raters near random chance distinguishing real vs simulated gameplay.

### LLM Planning & Search

**LATS: Language Agent Tree Search** (Zhou et al., ICML 2024, arXiv:2310.04406). Adapts MCTS for language agents — the LLM serves as action generator, value function, and reflection mechanism simultaneously. Failed trajectories produce self-critiques for future trials. Directly applicable for enemy AI planning combat strategies or narrative AI planning quest arcs.

**RAP: Reasoning with Language Model is Planning with World Model** (Hao et al., EMNLP 2023, arXiv:2305.14992). Uses the LLM itself as a world model to predict state transitions, applying MCTS for strategic exploration. LLaMA-33B with RAP surpassed GPT-4 with chain-of-thought by 33% in plan generation.

**ReAct** (Yao et al., ICLR 2023, arXiv:2210.03629). Interleaves reasoning traces and task-specific actions. Core pattern for any LLM agent that needs to reason about game state and take actions.

### LLM-Driven Game Content

**MarioGPT** (Sudhakaran et al., NeurIPS 2023, arXiv:2302.05981). Fine-tuned GPT-2 for generating Super Mario Bros levels from text prompts. Pioneering text-conditioned 2D level generation.

**Oasis** (Decart/Etched, Oct 2024). Real-time Minecraft-like experience entirely via transformer, no game engine. 500M parameters, 20 FPS at 360p.

**Unbounded** (Li et al., Oct 2024, arXiv:2410.18975). All game mechanics, characters, environments, and narrative produced by generative models — closest existing work to a fully generative RPG.

### LLM as Game Master

**CALYPSO** (Zhu et al., AIIDE 2023, arXiv:2308.07540). LLM-powered D&D assistant. Key philosophy: AI augments the human DM, doesn't replace them. Generated high-fidelity text suitable for direct player use. Aligns with your validator approach.

**RPGBench** (Yu et al., NeurIPS 2025, arXiv:2502.00595). First benchmark for LLMs as RPG engines. Critical finding: LLMs produce engaging stories but struggle with consistent, verifiable game mechanics. Validates your design decision to keep combat in traditional code and delegate narrative to LLMs.

**PANGeA** (Buongiorno et al., AIIDE 2024, arXiv:2404.19721). Memory + validation + LLM interface for RPGs. The validation system improved Llama-3 8B accuracy from 28% to 98% and GPT-4 from 71% to 99%. This is the closest system to your proposed architecture and the strongest evidence that a validation layer is essential.

**RPGAgent** (CHI 2026). Multi-agent system transforming story outlines into playable RPGs using GPT-4o with supervised fine-tuning. Outperformed baselines in user experience and creative satisfaction.

**Drama Llama** (Sun et al., Jan 2025, arXiv:2501.09099). Combines storylet-based systems with LLM generation. Authors define triggers in natural language rather than code.

**IBSEN** (Han et al., ACL 2024, arXiv:2407.01093). Director-actor multi-agent framework — a director agent writes plot outlines and instructs actor agents to role-play characters. Director reschedules plot when players participate. Maps directly to game master + NPC architecture.

### Key Surveys

- "A Survey on Large Language Model-Based Game Agents" (Hu et al., ACM Computing Surveys 2024, arXiv:2404.02039)
- "Large Language Models and Games: A Survey and Roadmap" (Gallotta et al., IEEE ToG 2024, arXiv:2402.18659)
- "Procedural Content Generation in Games with Insights on Emerging LLM Integration" (Maleki & Zhao, AIIDE 2024, arXiv:2410.15644)

---

## 2. AI Story Generation

### Commercial Systems

**AI Dungeon / Voyage** (Latitude, 2019-present). Architecture evolved from GPT-2 124M to model-agnostic (GPT-4, Llama 3, Mixtral). Context system uses Story Cards (triggered context injection — when a trigger word appears, the card's content is injected into the LLM prompt) and a Memory Bank (every 6 actions, an AI summary is created and embedded; when context overflows, an embedding model ranks all memories by relevance). In April 2026, Latitude launched **Voyage** with a World Engine tracking health, inventory, currency, geography, and relationships across thousands of turns. Story Cards are directly analogous to what your RPG needs — triggered context for techniques, cultivation stages, NPC personalities, and world lore.

**Charisma.ai** (Oxford, founded 2016). Hybrid story graph + generative AI. Visual node-based editor where developers map story beats; within guardrails, AI generates dialogue. Emotion Manager tracks character emotions, moods, relationships. The hybrid structured-graph + generative approach is the most robust commercial model.

**Inworld AI** (founded 2021, $500M+ valuation). Three-layer architecture: Character Brain (20-30+ AI models for personality, emotions, memory, goals), Contextual Mesh (knowledge bases, narrative constraints, rules — prevents hallucinations), Real-Time AI (scalability). The Contextual Mesh is the closest commercial analog to your validator.

**Spirit AI / Character Engine** (London, founded 2015). Emily Short was Chief Product Officer. Uses search-based expansion grammar that assembles responses from pre-authored fragments via NLU + knowledge model. NOT generative LLM — guarantees coherence via fragment assembly. A hybrid approach (LLM + pre-authored rules) combines both strengths.

### Narrative Coherence Research

**FACTTRACK** (Lyu et al., NAACL 2025, arXiv:2407.16347). Four-step pipeline: decompose events into atomic facts, determine validity intervals, detect contradictions, update world state. The "validity interval" idea is critical — a technique learned in session 3 is valid from then on; a qi depletion event has bounded duration. This is the closest existing work to your validator concept.

**SCORE** (Yi et al., 2025, arXiv:2503.23512). Dynamic State Tracking via symbolic logic, Context-Aware Summarization with hierarchical summaries, Hybrid Retrieval (TF-IDF + cosine similarity). Achieves 23.6% higher coherence, 89.7% emotional consistency, 41.8% fewer hallucinations vs baseline GPT.

**DOME** (Wang et al., NAACL 2025, arXiv:2412.13575). Uses a temporal knowledge graph (entity quadruples: subject-relation-object-chapter) as external memory. This maps perfectly to cultivation state — (Player, learned, "Iron Body Technique", Chapter 3).

**RecurrentGPT** (Zhou et al., ICLR 2024 Spotlight, arXiv:2305.13304). Simulates RNN recurrence in natural language. At each timestep, generates a paragraph and updates language-based long-short term memory stored externally. Human-readable and editable memory enables interactive co-authoring. Your RPG could maintain both structured state (for validation) and natural-language memory (for context injection).

### Story Planning

**Dramatron** (Mirowski et al., Google DeepMind, CHI 2023, arXiv:2209.14958). Hierarchical prompt chaining: log-line → characters → scene summaries → locations → full dialogue. Each level conditions on structured output from the previous level. Directly applicable: quest premise → scene outlines → actual dialogue, each conditioned on game state.

**Neural Story Planning** (Ye et al., 2022, arXiv:2212.08718). Backward chaining from story endings, querying the LLM for preconditions. Applicable to quests: define the goal ("player masters Iron Body Technique"), backward-chain through preconditions (meditation sessions, materials, teacher NPC).

**ASP-guided Story Generation** (Wang & Kreminski, Wordplay 2024, arXiv:2406.00554). Answer Set Programming to specify narrative constraints symbolically. A solver enumerates all valid outlines. Could encode cultivation rules: "a breakthrough scene cannot occur before a training montage scene."

### Story Sifting & Emergent Narrative

**Story Sifting** (James Ryan, UC Santa Cruz, 2018 PhD dissertation). Instead of bending simulations toward narrative, simulate extensively then curate via sifting patterns (matching event formats) and sifting heuristics.

**Felt / Winnow** (Max Kreminski, ICIDS 2019/2021). Logic-programming-based story sifters. Winnow detects storyful event sequences as they happen (prospective) or after the fact (retrospective).

**Awash** (Clothier & Millard, ICIDS 2023). Prospective story sifting + drama management. A sifter identifies possible stories during play and passes them to a drama manager that intervenes in the simulation. Increases narrative completeness without compromising emergent aesthetics. Highly relevant: your RPG could run background sifting on game events, detecting when interesting patterns emerge (rivalry forming, technique nearing breakthrough) and triggering quest generation.

### Drama Managers

**Facade** (Mateas & Stern, 2003-2005). Drama manager sequences beats scored against an Aristotelian tension arc. Forward-chaining rule system for NL understanding.

**PaSSAGE** (Thue et al., AIIDE 2007). Player-Specific Stories via Automatically Generated Events. Learns a player model (fighter, power gamer, tactician, storyteller, method actor) and dynamically selects content. Directly applicable: detect whether a player prefers combat, meditation, social intrigue, or exploration, and bias generation accordingly.

### Structured Narrative Generation (Recent)

**Function Calling for Game State** (Song et al., 2024, arXiv:2409.06949). The LLM doesn't modify state directly — it calls validated functions like `learn_technique("Iron Body")`. The cleanest architectural pattern for your validator.

**XGrammar** (Nov 2024, arXiv:2411.15100). Pushdown automaton parser enforcing JSON/grammar constraints during generation. Up to 100x latency reduction. Integrated into MLC-LLM. Essential for guaranteeing parseable structured output from the LLM.

---

## 3. Procedural Generation Inspirations

### Minecraft — Layered Noise Terrain

Uses five noise parameters (continentalness, erosion, peaks/valleys, temperature, humidity). A "noise router" feeds shared noise into terrain shape, biome selection, cave generation, and ore placement simultaneously. 3D density functions enable overhangs and caverns. Structures use a "jigsaw" system: hand-designed modular pieces assembled from template pools with connection points.

**Relevance:** Your six generation layers (Terrain, Mana density, Civilization, Sites, Conflict, Story packet) map directly to Minecraft's noise router. Mana density could be a noise parameter alongside terrain, making geography and mystical properties intrinsically linked. High mana density naturally produces denser spawning, faster flesh decay, richer artifact rolls — all deriving from the same underlying field.

### Dwarf Fortress — Simulated World History

Generates terrain, then simulates centuries of history with thousands of individually-modeled agents (500+ personality traits, memories, skills). Wars, artifacts, site founding, assassinations emerge from agent interactions. Artifacts encode their creator's emotional state.

**Relevance:** The model for generating your world's backstory before a playthrough begins. Simulate centuries of sect history: founding, wars, lost techniques, fallen cultivators, corruption outbreaks. When a player finds an artifact in a ruin, the LLM weaves its procedural history into contextual narrative.

### Caves of Qud — THE Most Relevant Reference

**Sultan Histories:** 5 procedurally generated historical sultans per playthrough, each with 10-22 biographical events via state machine + replacement grammar. Events generated first, rationalized post-hoc (mimicking real mythology). A 40,000-word authored corpus establishes voice; replacement rules codify diction and repackage it procedurally.

**Mutation System:** Two paths: Mutated Human (mutations) vs True Kin (cybernetics). Chimera morphotype: buying a mutation carries a rider effect — you grow a new body part. New limbs can grow from Chimera-grown limbs, creating bizarre anatomy. Unstable Genome: 33% chance per level-up of destabilization. Mental mutations increase Glimmer, attracting dangerous esper hunters — power has a visible cost.

**Faction System:** 67+ persistent factions + procedurally generated sultan cults. Water Ritual: formal diplomatic mechanic where reputation is currency for learning skills, recruiting followers, acquiring secrets.

**Relevance:** Sultan biography approach maps to legendary cultivator histories. Chimera mutation is a near-perfect model for your flesh/corruption system. Glimmer directly parallels instability: more flesh use = more danger. Water Ritual maps to sect diplomacy — reputation as currency for technique access. Your LLM replaces Qud's Markov chains but needs the same curated cultivation corpus foundation.

### Hades — Procedural Room Assembly for 2D Action

Hand-painted rooms arranged in new orders each run. Branching paths show rewards before entry, turning navigation into strategic build-crafting. 21,020 voiced lines across 300,000 words. A priority-weighted dialogue queue filters conversations by conditions and weights by importance, avoiding repeats.

**Relevance:** The most realistic PCG model for a small team. Hand-craft encounter rooms and assemble procedurally. The "choose your door by reward" mechanic maps to cultivation decisions: seek a technique scroll, spirit stones, a flesh mutation opportunity, or a meditation point. Priority-weighted dialogue queue is the gold standard — your LLM can implement a dynamic version.

### Dead Cells — Graph-Based 2D Level Generation

Six-step hybrid pipeline: fixed world frame, 1,000+ hand-designed room tiles, concept graphs specifying length/complexity/pacing, constraint-satisfaction room placement, monster density via tiles-per-monster formula, loot distribution. Safe "Passage" zones between biomes for upgrades/healing.

**Relevance:** Graph-based approach is strongest for your 2D level generation. Define concept graphs per site type (cave, ruin, nest, shrine). Passage zones map perfectly to meditation waypoints. The "monsters per N tiles" formula directly applies to mana-density-driven monster spawning.

### Spelunky — Critical Path First

4x4 room grid. A critical path algorithm guarantees solvability before content is generated. Three-phase generation: layout, obstacles, monsters.

**Relevance:** Critical-path-first is essential. Generate the guaranteed traversal path first (entrance to boss/exit), then fill optional areas. Phase 1 = layout and critical path, Phase 2 = mana sources, corruption nodes, flesh timers, Phase 3 = enemies scaled to mana density.

### No Man's Sky — Lessons from Scale

Technically infinite, emotionally empty. Random variation ≠ meaningful variation. The hundredth planet felt like the tenth.

**Lesson:** Procedural systems need strong artistic constraints per biome/mana level. Hand-crafted elements within procedural settings dramatically improve quality. Content needs meaning — connection to narrative, player goals, emotional stakes.

---

## 4. Story-Driven 2D Narrative Game Examples

### Hades — Story Woven into Roguelike Runs

Priority-weighted dialogue queue filters all possible conversations by gameplay conditions (weapon, death cause, relationship levels) and weights by importance. Story drip-fed 1-3 fragments per NPC per run, assembled cumulatively across dozens of runs. Every character remembers previous interactions.

**Relevance:** Your LLM can implement a more dynamic version — generating contextually appropriate responses based on corruption level, mutation tags, meditation history, relationship status, recent combat.

### Undertale — Consequence-Driven Narrative

Combat IS the moral choice interface. EXP = "EXecution Points" (gained only by killing), LV = "Level of Violence." The game permanently alters save files after Genocide route. Flowey is aware of save/load mechanics.

**Relevance:** Permanent consequence tracking for flesh/corruption. If a player pushes too far into flesh use, NPCs treat you differently, cultivation paths close, factions reject you. Understanding opponents via the LLM could unlock non-violent resolutions.

### CrossCode — Unified Mechanics

A single ball-throwing mechanic serves as foundation for combat, puzzles, and exploration simultaneously. Each elemental unlock changes both combat and puzzles.

**Relevance:** Qi/mana manipulation could unify combat, meditation, and exploration. The same energy system powers all three domains. Progressive capability unlocks tied to narrative (new cultivation realms → new techniques AND new meditation depths AND new world interactions).

### Disco Elysium — Dialogue-as-Gameplay

24 skills function as competing voices in the protagonist's head. Thought Cabinet: 12 mental slots where the player internalizes concepts with a Research phase (temporary penalty) and Completion phase (permanent effect).

**Relevance:** Maps perfectly to cultivation inner-world mechanics. Different paths manifest as competing internal voices during meditation. A corruption/flesh voice grows louder as instability increases. Thought Cabinet IS your meditation system: internalizing a manual passage uses a similar slot-based system with research phases before mastery.

### Wildermyth — Procedural Story Generation

"String of pearls": authored required modules (beginning, climax, ending) with procedurally-selected modules filling gaps. Transformation system replaces body parts. Each maiming triggers a themed replacement. Legacy system: surviving heroes enter a pool for future campaigns.

**Relevance:** The modular story approach is the critical pattern for LLM-driven narrative. Author key sect events, tribulation moments, breakthrough scenes. Let the LLM generate connective tissue. Progressive body transformation maps directly to flesh/corruption: each flesh use adds a mutation tag to a body part.

### Caves of Qud (Narrative)

"Generate events first, rationalize later" for sultan biographies. 40,000+ words of authored prose establish voice that the replacement grammar replicates.

**Key lesson:** Where Qud uses Markov chains, your LLM replaces the grammar engine but needs the same quality foundation. Build extensive style guides and voice templates in the martial-fantasy register.

### Slay the Princess — Constrained Depth

Repeating time-loop on an extremely constrained scenario. The Princess physically transforms based on how the player treats her. Every death adds a persistent voice to the player's head.

**Relevance:** Your corruption/mutation system could work similarly: how the player interprets and responds to transformation literally changes what they become. Failed breakthroughs could add persistent "voices" or internal states.

### Pentiment — Time Pressure as Narrative

No correct answer to investigations. Finite time slots per day — can't follow every lead. 25-year span across three acts where community evolves.

**Relevance:** Flesh timer creates the same "incomplete information, forced prioritization" tension. Different cultivation traditions could have distinct visual text styles (archaic calligraphy for dao texts, jagged script for demonic whispers).

### Cultivation/Xianxia Games

**Tale of Immortal:** Living NPC world where every NPC has stats, skills, family, relationships, and independently adventures. Weakness: extremely grindy.

**Amazing Cultivation Simulator:** Deepest cultivation mechanics in any game. Golden Core quality = `Law Match × Luck × Season × Weather × Yin-Yang × Tile Qi × Mental State × Element Match`. Qi Deviation: losing focus causes self-injury. Weakness: overwhelming complexity, terrible onboarding.

**The Genre Gap:** No existing game combines deep cultivation mechanics with strong authored narrative. This is a significant design opportunity.

---

## 5. Engine Evaluation

### Godot 4 — Primary Recommendation

2D is a first-class citizen with a dedicated renderer. TileMapLayer system is mature for top-down RPGs. Benchmarks: ~75 FPS vs Unity's ~65 FPS for comparable 2D workloads. Proven by Brotato (10M+ copies), Halls of Torment, Dome Keeper, Cassette Beasts.

**Procedural generation:** Built-in FastNoiseLite, runtime scene instantiation, programmatic TileMapLayer manipulation. BSP and WFC implementations exist. Godot 4.5 added chunk-based tilemap physics improvements.

**LLM integration:** Godot LLM Framework (Asset Library) supports Anthropic Claude and OpenAI with async operations. HTTPRequest node handles REST API calls natively. Streaming via ChatGPT-stream-for-Godot-4. godot-llama.cpp GDExtension enables local inference without internet. Sidecar architecture (Ollama/llama.cpp as separate process) is recommended.

**Modding:** Godot Mod Loader is battle-tested (used by Brotato, Dome Keeper). Mods distributed as ZIPs.

**Dialogue:** Dialogic 2 provides visual timeline editing, branching narratives, variable manipulation.

**Verdict:** Strongest overall candidate. Covers 80-90% of needs out of the box.

### Alternatives Considered

**Phaser/TypeScript (web):** Easiest LLM integration (native fetch, npm ecosystem). Best for a throwaway vertical slice prototype. Not suitable as shipping product — browser performance ceiling, no native gamepad feel.

**Unity:** Massive ecosystem, C#/.NET for LLM SDKs. But runtime fees, 30+ second reimport times, 2D is second-class in a 3D engine. Overweight for this project.

**Bevy (Rust):** True ECS, cache-friendly data layout, excellent for procedural generation with many entities. But pre-1.0, no editor, steep learning curve, slow iteration for content-heavy games.

**Custom engine (Raylib/SDL2):** Total control but 6-18 months of engine development before game code. 30-60% budget increase. Only viable if engine development is part of the fun.

### Recommendation

**Godot 4 for shipping.** Optionally, spend 2-4 weeks on a Phaser/TypeScript throwaway prototype to validate LLM dialogue architecture, procedural generation algorithms, and combat feel before committing. If you need heavy Python-side logic (ML models, NLP), run as a separate local service and call via HTTP from Godot.

---

## 6. Meridian Flow Reusability Assessment

The `h/v3` branch of [meridian-flow](https://github.com/haowjy/meridian-flow/tree/h/v3) is a TypeScript-first writing platform for fiction writers managing long-running web serials (xianxia, LitRPG, progression fantasy). It's a monorepo (pnpm + Nx) with a React frontend (TanStack Start + TipTap editor), Nitro backend, and PostgreSQL via Drizzle ORM.

### What maps well to a game engine

**Document-as-state:** The `contextSources → folders → documents` hierarchy is already a file-system abstraction. Game state files (character sheets, world maps, inventory, quest logs) map naturally to documents within context sources. The `markdownProjection` field with FTS indexes already supports searching game state.

**Agent thread runtime:** The thread/turn/block model with spawn trees, checkpoints, and event journals is a strong foundation for LLM-driven narrative. The interrupt/checkpoint system could serve as the "player choice" mechanism. `workingState` on threads maps to current quest/objective state.

**Agent definitions + skills:** Configurable agents with models, tools, system prompts, and attachable skill documents — directly reusable for game agents (narrator, NPC dialogue, combat resolver, world builder).

**Draft review workflow:** Yjs-based draft system (AI proposes changes, human accepts/rejects) could serve as "proposed narrative outcome" that the player reviews.

**Event journal:** Append-only event journal with typed events — already an event-sourcing pattern ideal for game state history.

### What's missing

**No vector/embedding search.** Full-text search only (Postgres GIN + trigram). No pgvector, no embedding tables, no embedding API calls. This is the biggest gap.

**No game-specific schemas.** Needs player state, game sessions, world state snapshots, action resolution records, NPC state machines.

**SaaS dependencies.** WorkOS auth, Stripe billing, AWS S3 — all need replacement or simplification for a game.

**No game loop.** Current real-time layer is Yjs document sync, not a tick-based game loop.

### Verdict

The backend infrastructure is ~40-50% reusable: database layer, agent thread runtime, event journal, spawn trees, LLM provider adapters, document hierarchy. The contracts package is well-structured for extension. The frontend is NOT reusable (manuscript editing). Strongest reuse path: keep `@meridian/contracts`, `@meridian/database`, and server domain orchestration as a "game narrative engine" backend.

---

## 7. Local LLM, Embeddings, and Vector Search

### Local Small LLMs for Game Bundling

**llama.cpp** is the standard. Written in C/C++ with SIMD optimization, 3-8x faster than Python frameworks. GGUF format is the universal model packaging format. Already integrated into games: Llama-Unreal plugin for UE5, godot-llama.cpp GDExtension for Godot, both supporting embedded or sidecar inference.

**Recommended models for games:**

| Model | Parameters | Q4 Size | Use Case |
|-------|-----------|---------|----------|
| Qwen2.5 3B | 3B | ~2 GB | Ambient NPCs, simple dialogue |
| SmolLM3 3B | 3B | ~2 GB | Best-in-class at 3B size |
| Phi-4-mini | 3.8B | ~2.5 GB | Best small reasoner |
| Qwen2.5 7B | 7B | ~4.5 GB | Named story characters, complex narrative |
| Eva Qwen 2.5 7B | 7B | ~4.5 GB | Best uncensored roleplay model |

**Inference speeds (Q4_K_M quantization):**

| Hardware | 3B Model | 7B Model |
|----------|----------|----------|
| RTX 3060 12GB | ~60+ tok/s | ~42 tok/s |
| RTX 4070 | ~80+ tok/s | ~52 tok/s |
| CPU only (modern) | ~15-20 tok/s | ~8-12 tok/s |

At 42 tok/s for a 7B model on an RTX 3060, a 100-token NPC dialogue response takes ~2.4 seconds. With streaming, the first tokens appear in <200ms. This is fast enough for dialogue if you design around it (mask with animations, show text appearing character-by-character).

**Deployment:** Ship Ollama or llama.cpp as a sidecar binary, adding ~2 GB to install size. Sub-millisecond loopback HTTP round-trips between game and inference server. Models ship with packaged builds automatically in Unreal; similar pattern works with Godot.

### Local Embedding Models

**Nomic Embed v2** (137M parameters, 274 MB download) is the top recommendation for CPU-only environments. Best quality-to-size ratio available. Supports Matryoshka dimensions (768 down to 64), 8192 token context.

**all-MiniLM-L6-v2** (46 MB download) is the lightest option. Excellent when speed matters most but outperformed on retrieval by newer models.

**BGE-small** offers a balance of power and efficiency between MiniLM and Nomic.

All run well on CPU via ONNX Runtime. For a game, embedding generation latency on CPU is typically 5-20ms per document — fast enough for real-time use. You'd generate embeddings at save points or scene transitions, not during action gameplay.

### Local Vector Databases

**sqlite-vec** is the clear winner for game bundling. Written in pure C, zero dependencies, MIT licensed, runs anywhere SQLite runs (including WASM). Successor to sqlite-vss. Lightweight enough for edge/mobile deployment. Handles up to ~1M vectors comfortably. Your game state is already in SQLite (or could be) — adding vector search to the same database eliminates an entire dependency.

**LanceDB** is stronger for larger corpora (1M+ vectors) with disk-based storage via the Lance columnar format. Supports automatic versioning, hybrid search (vector + full-text + SQL filtering), and time-travel queries. More features than sqlite-vec but heavier.

**ChromaDB** (local mode) is easiest to prototype with but keeps data in memory. The 2025 Rust rewrite improved performance 4x. Good for development, but sqlite-vec is more appropriate for shipping.

### Recommended Stack

For a game that organizes state around files with local LLM inference:

```
Game Engine (Godot)
  ↕ HTTP/loopback
Local Inference Sidecar (llama.cpp server)
  - Qwen2.5 3B Q4 for ambient NPCs (~2 GB)
  - Qwen2.5 7B Q4 for story characters (~4.5 GB)
  ↕
SQLite + sqlite-vec
  - Game state in regular tables
  - Embeddings in vec0 virtual tables
  - Nomic Embed v2 via ONNX Runtime for embedding generation
```

Total additional install size: ~7-9 GB (models + runtime). Modern AAA games are 50-150 GB. This is completely acceptable.

### Performance Strategy

1. **Pre-generate** dialogue during non-critical moments (loading, travel, meditation animations)
2. **Stream** responses to mask latency (text appearing character by character)
3. **Cache** frequently-used NPC greetings and common responses
4. **Use smaller model** (3B) for ambient/simple NPCs, larger (7B) for story-critical characters
5. **Embeddings on CPU** — fast enough (5-20ms) and doesn't compete with GPU inference
6. **Background inference** — queue generation requests during gameplay, deliver results when player enters dialogue

---

## 8. Architecture Recommendations

Based on all research, the optimal architecture combines:

1. **Deterministic runtime owns all game state.** Combat, physics, inventory, timers, world state — traditional code. The LLM never directly mutates state. (Validated by RPGBench, PANGeA.)

2. **Function calling for state changes.** The LLM proposes changes via structured function calls (`learn_technique("Iron Body")`, `advance_cultivation("Foundation Stage 3")`). Functions validate against game rules before executing. (Song et al. 2024.)

3. **Temporal knowledge graph memory.** Store game facts as (subject, relation, object, timestamp) quadruples. The validator checks new facts against existing ones with temporal awareness. (DOME, FACTTRACK.)

4. **Triggered context injection (Story Cards).** Define trigger words for techniques, sect lore, NPC personalities. Auto-inject relevant context when triggers appear. (AI Dungeon/Voyage.)

5. **Hybrid retrieval.** Combine keyword matching (technique names, NPC names) with semantic similarity (sqlite-vec embeddings) to select relevant context for each generation call. (SCORE.)

6. **Prospective story sifting.** Background process monitoring game events for emerging narrative patterns, triggering quest generation when interesting patterns are detected. (Awash, Kreminski.)

7. **Hierarchical generation.** Quest premise → scene outlines → actual text. Each level validated separately. (Dramatron.)

8. **Constrained decoding.** For structured outputs (quest specs, state updates), enforce JSON schema at the token level. (XGrammar.)

9. **Player modeling.** Track preferences (combat vs training vs social) and bias generation accordingly. (PaSSAGE.)

10. **Curated cultivation corpus.** Following Caves of Qud's 40,000-word foundation, build extensive style guides and voice templates in the martial-fantasy register so LLM output sounds authentic.

---

## Sources

### Papers & Academic Work
- [Generative Agents (Park et al. 2023)](https://arxiv.org/abs/2304.03442)
- [Voyager (Wang et al. 2023)](https://arxiv.org/abs/2305.16291)
- [SPRING (Wu et al. 2023)](https://arxiv.org/abs/2305.15486)
- [World Models (Ha & Schmidhuber 2018)](https://arxiv.org/abs/1803.10122)
- [Genie (Bruce et al. 2024)](https://arxiv.org/abs/2402.15391)
- [GameNGen (Valevski et al. 2024)](https://arxiv.org/abs/2408.14837)
- [LATS (Zhou et al. 2023)](https://arxiv.org/abs/2310.04406)
- [RAP (Hao et al. 2023)](https://arxiv.org/abs/2305.14992)
- [ReAct (Yao et al. 2022)](https://arxiv.org/abs/2210.03629)
- [CALYPSO (Zhu et al. 2023)](https://arxiv.org/abs/2308.07540)
- [RPGBench (Yu et al. 2025)](https://arxiv.org/abs/2502.00595)
- [PANGeA (Buongiorno et al. 2024)](https://arxiv.org/abs/2404.19721)
- [IBSEN (Han et al. 2024)](https://arxiv.org/abs/2407.01093)
- [Drama Llama (Sun et al. 2025)](https://arxiv.org/abs/2501.09099)
- [Dramatron (Mirowski et al. 2023)](https://arxiv.org/abs/2209.14958)
- [FACTTRACK (Lyu et al. 2025)](https://arxiv.org/abs/2407.16347)
- [SCORE (Yi et al. 2025)](https://arxiv.org/abs/2503.23512)
- [DOME (Wang et al. 2025)](https://arxiv.org/abs/2412.13575)
- [RecurrentGPT (Zhou et al. 2023)](https://arxiv.org/abs/2305.13304)
- [MarioGPT (Sudhakaran et al. 2023)](https://arxiv.org/abs/2302.05981)
- [Unbounded (Li et al. 2024)](https://arxiv.org/abs/2410.18975)
- [XGrammar (2024)](https://arxiv.org/abs/2411.15100)
- [Function Calling for Game State (Song et al. 2024)](https://arxiv.org/abs/2409.06949)
- [ASP Story Generation (Wang & Kreminski 2024)](https://arxiv.org/abs/2406.00554)
- [Neural Story Planning (Ye et al. 2022)](https://arxiv.org/abs/2212.08718)
- [Player-Driven Emergence (Peng et al. 2024)](https://arxiv.org/abs/2404.17027)

### Tools & Engines
- [llama.cpp](https://github.com/ggml-org/llama.cpp)
- [Godot LLM Framework](https://github.com/playajames760/Godot-LLM-Framework)
- [godot-llama.cpp](https://deepwiki.com/thalloerupt/godot-llama.cpp)
- [Godot Mod Loader](https://github.com/GodotModding/godot-mod-loader)
- [sqlite-vec](https://github.com/asg017/sqlite-vec)
- [LanceDB](https://lancedb.com/)
- [Ollama Embedding Models Benchmarked](https://www.morphllm.com/ollama-embedding-models)
- [Best Open-Source Embedding Models](https://www.bentoml.com/blog/a-guide-to-open-source-embedding-models)

### Game References
- [Local AI NPCs for Game Dev (2026)](https://localaimaster.com/blog/local-ai-game-npcs)
- [Running Local LLMs in Godot + Ollama](https://dev.to/ykbmck/running-local-llms-in-game-engines-heres-my-journey-with-godot-ollama-4hhd)
- [LLM Inference Speed Benchmarks](https://singhajit.com/llm-inference-speed-comparison/)
- [Vector Database Comparison 2026](https://4xxi.com/articles/vector-database-comparison/)
- [Chroma vs LanceDB](https://agntup.com/chroma-vs-lancedb-best-vector-database-for-side-projects-in-2026/)
- [Small Language Models Ranked 2026](https://localaimaster.com/blog/small-language-models-guide-2026)
