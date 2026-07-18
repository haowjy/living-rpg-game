# Living RPG

Living RPG is a presentation-first fantasy RPG built for LLM direction. The
player explores a persistent 2D/2.5D world, deals with people who remember what
happened, enters repeatedly generated Dungeons, fights deterministic turn-based
battles, and develops techniques and weapons shaped by their history.

The project follows one boundary:

> The LLM proposes or interprets what is meaningful. Deterministic code
> establishes what is true. The presentation makes it felt.

## Current target

The first slice is a polished, mobile-capable stage with:

- top-down movement and expressive dialogue presentation;
- a narrow Director command vocabulary usable by scripts and LLMs;
- deterministic state, time, combat, spawning, save/load, and replay;
- people with knowledge, memories, requests, and commitments;
- one procedural Dungeon and one remembered consequence;
- validated technique evolution and semi-deterministic weapon upgrades.

There is no conventional quest checklist. People ask for things, the world
continues, and later behavior reflects what the player did or forgot.

## Architecture

```text
player input | authored script | deterministic AI | LLM adapter
                              |
                              v
                    validated commands
                              |
                              v
                    deterministic state
                              |
                              v
                     canonical events
                       /           \
                      v             v
              presentation      world memory
```

Every LLM path has structured proposals, validation, traceability, and a
deterministic fallback. LLMs never mutate canonical state or control movement
and animation frame by frame.

## Repository

| Path | Purpose |
|---|---|
| `design/` | Current product direction, system design, and implementation contracts |
| `godot/` | Existing deterministic game and presentation prototype |
| `docs/` | Workflow and prototype handoff documentation |
| `agents/`, `tools/`, `world-state/`, `tests/` | Reserved LLM-engine surfaces; intentionally empty until implementation direction settles |

TypeScript is the current preference for the Director protocol and future
implementation, but no final framework has been ratified. See the
[design overview](design/pages/overview.md), [first slice](design/pages/prototype.md),
and [decision log](design/pages/decisions.md).

Related work:

- [living-rpg-public](https://github.com/haowjy/living-rpg-public)
- [creative-writing-skills](https://github.com/haowjy/creative-writing-skills)
- [meridian-prompter](https://github.com/haowjy/meridian-prompter)
