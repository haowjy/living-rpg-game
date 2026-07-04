# World Generation and Sites

World generation creates a continuous, explorable region from a single seed. The world exists as a master map of undiscovered areas. Detail generates on demand as the player explores, locks when loaded, and persists from that point forward.

## Chunk-Based World Generation

The world uses a Minecraft-style chunk system adapted for 2.5D tiles.

### Layer 1: World Seed → Master Map

A seed generates a high-level region map before the player starts. This map defines:

- **Biomes** — forest, plains, hills, swamp, mountains, coastline
- **Elevation heightmap** — coarse elevation data for the region
- **River and road networks** — water flows and travel routes connecting settlements
- **Pinned locations** — towns, ruins, faction HQs, shrines, and other important sites placed at specific coordinates

The player sees this as a stylized overview map with fog-of-war over unexplored areas. Important locations appear as icons or markers based on rumors and NPC information — the player knows "there's a town to the north" before they've been there. Nothing is rendered in tile detail until the player approaches.

### Layer 2: Chunk Generation on Approach

When the player gets near an unloaded area, a chunk generates and locks permanently. A chunk is a tile grid (32x32 or 64x64 tiles). Generation reads from the master map:

- What biome is this chunk in?
- What elevation range does it cover?
- Does a road or river pass through?
- Is there a pinned structure here?
- What faction controls this area?

The chunk generates once and never regenerates. Changes after generation (a building burns down, a camp is established, trees are cleared) are state mutations on the locked chunk, not regeneration.

### Layer 3: Chunk Composition from Prefabs

Chunks are not built tile-by-tile from noise functions. They are assembled from **prefab templates** — hand-designed tile arrangements that an artist creates. The generator selects, rotates, mirrors, and connects prefabs based on the chunk's parameters.

Prefab examples:

| Prefab | Tiles | Used when |
|---|---|---|
| Forest clearing | Trees around edges, grass center, campfire spot | Forest biome, no structures |
| Road fork | Dirt path splitting, road sign, grass borders | Road network intersection |
| Hill watchtower | Cliff-face tiles, elevated plateau, staircase path, tower structure | Pinned watchtower at elevation |
| Village square | Cobblestone grid, well, building slots around edges | Pinned village location |
| River crossing | Water tiles, bridge structure, muddy banks | Road meets river |
| Bandit camp | Tents, firepit, log barricade, forest edge | Faction camp placement |
| Shrine clearing | Stone tiles, altar structure, overgrown edges | Pinned shrine location |
| Cave entrance | Rock face tiles, dark opening, scattered stones | Pinned cave/dungeon |

An artist designs 50-100 prefabs. The generator picks the right one for each chunk's parameters. This solves the elevation problem — a "hill with watchtower" prefab uses cliff-face tiles, elevated plateau tiles, and a winding path. The procedural system places the prefab; it doesn't figure out how to tile a hill from scratch.

Prefabs connect at edges using a constraint system — road exits must line up with neighboring chunks, biome transitions use auto-tiling borders, elevation changes match at chunk boundaries.

### Layer 4: LLM Enrichment

After a chunk locks, the LLM reads it and writes the semantic layer:

- Who lives here or patrols here?
- What happened here recently?
- What pressure exists (faction tension, monster threat, resource scarcity)?
- What rumors or story hooks attach to this place?

The tiles are set by the generator. The meaning is set by the LLM. A "forest clearing" prefab becomes "the clearing where the Red Sashes ambushed a merchant caravan last week — drag marks lead north, and crows circle overhead" because the LLM reads the world state and writes that context.

## Site Vocabulary

The region uses a vocabulary of site types:

Town, district, village, road, mill, farm, shrine, ruined fort, bandit camp, monster nest, cave, watchtower, crossroads, bridge, quarry, mine.

Each site type carries default assumptions about what the player can do there, what factions care about it, and what pressure it produces.

## Site Meaning

Every important site answers three questions: who wants this place, why, and what changes if the player interferes?

| Site | Material value | Story value |
|---|---|---|
| North Mill | Food, taxes, road logistics | Legitimacy crisis for the local ruler |
| Abandoned Shrine | Power source, hidden lore, shelter | Claimable base and dangerous spiritual history |
| Red Sash Camp | Weapons, recruits, stolen goods | Enemy base or early faction foundation |
| Ruined Watchtower | Territory control, scouting, defense | First visible claim on the map |

Sites that lack both material and story value should not exist. Every location should pull its weight.

## V1 Tile Rendering

V1 renders chunks in a 2.5D three-quarter perspective using three visual layers:

| Layer | Content | Source |
|---|---|---|
| Terrain tiles | Ground types — cobblestone, dirt, grass, water, stone, cliff faces | Prefab template + auto-tiling for edges |
| Structures | Buildings, walls, bridges, fences — composed from modular parts | Prefab template with randomized variations |
| Props and NPCs | Market stalls, barrels, lanterns, trees, character sprites | World state: who is here, what's present |

Background layers (distant mountains, sky, clouds) are parallax-scrolling painted art, not tiles. Elevation within a chunk is handled by the prefab design — cliff tiles, plateau tiles, stairs — not by smooth heightmaps.

Art style: anime-inspired pixel art, 32x32 tile scale. Grounded medieval tone. Reference: CrossCode, Eastward.
