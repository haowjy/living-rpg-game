# Agent Architecture

The game engine is an LLM agent loop over a structured file system. The LLM reads world state from files, writes narration as free text, and calls tools when state needs to change.

## Core Loop

```
read world state (files + index)
    → observe (what changed, what's nearby, what's pressured)
    → think/write (narration, dialogue, scene prose)
    → call tools (state mutations: move character, write event, update relationship)
    → loop
```

The LLM's primary output is prose. Structured JSON is only used for state mutations via tool calls. JSON mode or constrained decoding handles format validity when structured output is needed.

## Agents and Skills

The PoC is a meridian package — a set of agents and skills, following the same pattern as the creative-writing-skills plugin. Agents and skills map from creative writing to game engine:

| Creative writing | Game engine |
|---|---|
| Muse (session lead, stance switching) | Game director (loop, observe, dispatch) |
| Writer (prose from briefs) | Narrator (prose from world state) |
| Critic (adversarial reading) | Validator (consistency checking) |
| Character-sim (in-character conversation) | NPC agents (interactive characters) |
| KB (durable story memory) | World state (characters, factions, locations) |
| Story memory (fact extraction) | Event log (what happened) |
| Vocab / shared-dao | World lore, canonical terms |

## State Mutations via Tools

State changes happen through tool calls. The LLM proposes a call; the tool validates and executes it.

```
move_character(character_id, destination_area)
write_event(event)
change_relationship(source_id, target_id, delta, reason)
spread_rumor(rumor_id, from_area, to_area)
claim_site(faction_id, area_id)
create_quest_thread(quest)
```

If a tool call references an invalid location, a character who is not present, or a faction that does not exist, the tool rejects it. The LLM retries once on failure, then falls back to a template appropriate to the scene type.

## Platform and Model Policies

The meridian package targets multiple platforms (opencode, Claude Code, etc.) via model policies. The default play experience runs on open platforms.

A setup skill provides instructions for configuring local models (Ollama, llama.cpp) as an alternative backend. The same agents and skills work regardless of which model serves the requests.

| Concern | Approach |
|---|---|
| Model selection | Model policies per platform — cloud default, local optional |
| JSON validity | Constrained decoding (JSON mode) |
| Semantic validation | Tool-level checks (presence, knowledge, rules) |
| Failure handling | Retry once, then graceful degradation (template fallback) |

## What the Architecture Replaces

The old design described ten named code modules (MapEngine, LocationTracker, StorySifter, StoryDirector, Narrator, Validator, ContentCompiler, etc.) connected in a rigid pipeline. The new architecture replaces all of them with four components:

1. **Files** — World state as a structured directory of prose and data files.
2. **Index** — FTS + vector search over those files for retrieval.
3. **Tools** — Named functions for state mutations, each with built-in validation.
4. **Loop** — The LLM agent reads, thinks, writes, calls tools, and repeats.
