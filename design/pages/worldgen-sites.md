# Overworld and Dungeons

The world has two spatial categories with different persistence rules:

- **Overworld:** regular space generated once, then kept.
- **Dungeon:** a lore-recognized special space that generates repeatedly and
  can spontaneously spawn monsters.

Both use the same movement, collision, interaction, and presentation systems.

## Overworld

A world seed establishes terrain, routes, settlements, landmarks, and Dungeon
entrances. Generation may occur ahead of play or lazily by area, but each area
locks after its first generation. Later changes are state mutations rather than
rerolls.

### Terrain generation

Seeded fields may describe:

- elevation and roughness;
- moisture and temperature;
- biome and vegetation density;
- water, shorelines, and traversability;
- road and river influence;
- suitability for landmarks and settlements.

Noise creates natural variation. Constraints and authored templates create
readable routes, settlements, interiors, and important compositions. The
generator must verify connectivity, legal spawn positions, and mobile
performance before accepting an area.

Important social spaces should remain deliberately composed even when their
surrounding terrain is procedural.

## Dungeons

Dungeons are not a generic word for caves or ruins. A regular cave is ordinary
geography. A cave, tower, forest, or impossible interior becomes a Dungeon only
when it has the world's special monster-generating condition.

A Dungeon definition needs only enough information to generate a playable
instance:

- seed and theme;
- danger and spawn budget;
- allowed terrain and room pieces;
- entrance and completion conditions;
- monster affinities or spawn table;
- required landmarks, if any.

Routine layout and monster spawning remain seeded and deterministic. The Oracle
may provide meaning or propose unusual events, but it does not paint tiles or
place an illegal monster.

## Monster spawning

When time advances or the player crosses a valid spawn boundary, the Dungeon
may spend part of its spawn budget. The system chooses an eligible location and
legal monster group from the current seed and rules. Population limits,
distance checks, terrain compatibility, and cooldowns prevent arbitrary or
unfair encounters.

Spawned monsters should normally exist visibly in the space. Entering combat
uses the same encounter system as authored enemies.

## Regeneration remains open

The project has not chosen whether a Dungeon regenerates on every entry, after
a timed refresh, by floor, or by expedition. That rule must eventually explain
what persists: discovered information, opened routes, defeated named monsters,
left items, and changes made by other people.

The cosmological origin of Dungeons and their monsters also remains open.

## Sites need consequences

An important overworld site or Dungeon landmark should answer:

1. Who cares about it?
2. What material or social value does it hold?
3. What changes if the player or another faction interferes?

Decorative locations may exist for atmosphere. The Oracle should not pretend
that every clearing is a story thread.
