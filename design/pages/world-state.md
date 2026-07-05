# World State

World state lives as files in a structured directory. The LLM reads prose and data files directly. An index (FTS + vector) provides search when the agent needs to find relevant context across the world. Tools are the only writers for canonical state.

## Directory Structure

```
world/
  world.md              # setting overview, current era, active pressures
  clock.md              # current day/hour, pending ticks

  areas/
    greyford/
      area.md            # description, control, exits, tags
      recent-events.md   # what happened here lately
      rumors.md          # what information has reached this place
      npcs-present.md    # who is here right now
      districts/
        market/
        church-hospital/
        adventurers-guild/

    north-mill/
      area.md
      recent-events.md

    red-sash-camp/
    abandoned-shrine/
    wolf-cave/
    ruined-watchtower/

  characters/
    player.md            # stats, inventory, skills, history
    mara-guild-clerk.md
    tomas-rival.md
    sister-elian.md

  factions/
    vael-lordship.md
    church-of-the-seal.md
    red-sash-bandits.md

  quests/
    reclaim-north-mill.md

  events/
    log.jsonl            # canonical append-only event log
    log.md               # readable projection of what happened
```

## Design Principles

> The file system is the world. If the LLM can read a file, it knows that thing. If no file exists, that thing has not been established.

Files are prose by default. The LLM reads them as context and writes narration in the same format. Structured data (stats, coordinates, relationship values) lives in fenced blocks within markdown files or in small data files where precision matters.

State mutations happen via tool calls, not by the LLM editing files directly. When the `move_character` tool fires, it updates the relevant area files and the character file. When `write_event` fires, it appends to the canonical JSONL event log and rebuilds readable projections.

The implementation-facing schemas are defined in [V0 Implementation Spec](implementation-spec.md).

## Index Layer

An index sits alongside the files to support retrieval:

| Index type | Purpose |
|---|---|
| Full-text search | Find events, characters, or locations by name or keyword |
| Vector search | Find thematically related content (e.g., "betrayal" surfaces relevant events even if the word was never used) |

The index is a derived projection of the files. It can be rebuilt from the directory at any time. It is never the source of truth.

## Events as Truth

Everything important that happens becomes an event in the log. Events are how the world remembers and how future story generation stays grounded. `events/log.jsonl` is canonical; `events/log.md`, area recent-event files, and index entries are rebuildable projections.

A typical event entry in `events/log.md`:

```
### Day 3, Hour 13 — Public Confrontation

**Location:** Greyford Market
**Actors:** Player, Tomas (rival adventurer)
**Factions involved:** Adventurers Guild
**Visibility:** Public

Tomas accused the player of taking Guild work above their rank.
Relationship with Tomas decreased. Rumor "arrogant newcomer" began spreading.
```

Events are append-only. They reference real characters, locations, and factions. The story system reads them to detect patterns and propose new developments.

## Browsing Axes

The directory supports two ways of understanding the world:

| Axis | Question | Example path |
|---|---|---|
| Area | What is happening at this place? | `areas/greyford/recent-events.md` |
| Quest | What story thread connects these events? | `quests/reclaim-north-mill.md` |
| Character | What does this person know and want? | `characters/mara-guild-clerk.md` |
| Faction | What is this group doing and why? | `factions/vael-lordship.md` |
