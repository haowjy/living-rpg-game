# Research Notes

Research from generative agent papers, LLM game experiments, and reference games reinforces the architecture: world state as files, LLM-driven story sifting, tool-validated state mutations, and hybrid memory retrieval.

## Key Takeaways

| Finding | Design consequence |
|---|---|
| Generative agents need memory, retrieval, and reflection | NPC agents have event memory, read their own history, and update their plans based on what happened |
| LLMs struggle with consistent verifiable mechanics | The LLM writes prose; tools own state mutations and validate them |
| Hybrid retrieval (FTS + vector) improves coherence | The index layer supports both exact search and thematic retrieval |
| Story sifting finds emergent patterns in event streams | The LLM reads events and proposes story threads — no rigid pattern-matching rules |
| Procedural scale can become empty | Start with one dense county where every site matters; do not generate a continent |

## Reference Games

Each reference teaches a different part of the design:

| Reference | What to borrow |
|---|---|
| Minecraft | Self-directed survival, exploration, resource pressure, player-owned goals |
| Echoes of Mystralia | Primary feature reference for "make your own spells" — extended here through insight-driven generative spellcrafting |
| Kenshi | Rise from nobody in a harsh world of factions and opportunity |
| Dwarf Fortress | World history, events, artifacts with backstory |
| Wildermyth | Procedural personal myth and character transformation |
| Caves of Qud | Deep strange systems, generated histories, authored voice foundation |
| AI Dungeon / Voyage | Infinite narrative ambition — and the cautionary failure mode of ungrounded generation |

## Warnings

**Pitch the player fantasy, not the technology.** "Rise from nobody to legend in a living world that remembers" is a game pitch. "AI-generated content" is a technology description that sounds vague and low-trust.

**Ground generation in state.** Freeform generation without state validation becomes mushy. The PoC is a real game simulation with text presentation, not an uncontrolled text toy.

**Start dense, not wide.** One region with real consequences beats a continent of shallow generated places. Every site, NPC, and faction in the PoC should pull its weight.
