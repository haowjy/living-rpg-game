# Living RPG Design

Living RPG is a presentation-first, LLM-directed fantasy RPG. The immediate
goal is a polished 2D/2.5D stage that deterministic code, authored scripts, and
LLMs can all direct through the same commands.

The project follows one boundary:

> The LLM proposes or interprets what is meaningful. Deterministic code
> establishes what is true. The presentation makes it felt.

## Read in this order

| Page | Question it answers |
|---|---|
| [Overview](pages/overview.md) | What game are we making? |
| [Prototype](pages/prototype.md) | What must the first playable slice prove? |
| [Agent architecture](pages/agent-architecture.md) | How do deterministic systems and LLMs share control? |
| [Story system](pages/story-system.md) | How does the Oracle turn remembered events into scenes? |
| [People, requests, and threads](pages/requests-threads.md) | What replaces a conventional quest log? |
| [World state](pages/world-state.md) | What does the world remember, and who may change it? |
| [Clock and agents](pages/clock-agents.md) | How does the world move without the player? |
| [World generation and Dungeons](pages/worldgen-sites.md) | How do persistent overworld space and recurring Dungeon space differ? |
| [Growth and power](pages/growth-power.md) | How do techniques, weapons, and broader power develop? |
| [Player character](pages/player-character.md) | What defines the player's mechanical and social identity? |
| [Implementation spec](pages/implementation-spec.md) | What are the first slice's concrete contracts? |
| [Decisions](pages/decisions.md) | Which choices are settled, superseded, or open? |

## Current direction

- Presentation comes first. The target is a mobile-capable,
  Pokémon Black/White-inspired 2D/2.5D game with real-time exploration,
  expressive dialogue, and deterministic turn-based combat.
- The story is chosen at meaningful moments by an LLM Oracle. Movement, time,
  legal actions, combat resolution, and canonical state remain deterministic.
- People make requests and remember promises. The player never receives a
  conventional objective checklist or `Quest Failed` notification.
- Techniques and weapons have deterministic mechanical bodies. LLMs may propose
  names, meaning, combinations, and upgrade paths within validated budgets.
- The overworld is generated once and persists. Dungeons are special spaces
  that generate repeatedly and spawn monsters under deterministic rules.
- The MVP is about people. Spirits remain possible later but are outside the
  first proof.

The [research report](research_report.md), [research notes](pages/research-notes.md),
and [image prompts](image_prompts.md) are source material, not current product
requirements. The decision log wins when they conflict with active design.
