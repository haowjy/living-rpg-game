# Site map format

`SiteMap` is the authored-data bridge to procedural world generation. A generator
can create a `.tres` in `game/data/content/maps/<area-id>.tres`; `WorldView` will
render it without a scene edit.

## Resource

```gdscript
id: String                         # must equal AreaDef.id
ground_rows: PackedStringArray     # H rows, each exactly W tile characters
overlay_rows: PackedStringArray    # H rows of W characters; space means empty
placements: Array[Dictionary]      # entities and interaction points
```

Both grids use 32 px tiles, have identical dimensions, and are rectangular. Put
one terrain character in every ground cell. Overlay is transparent where it has
a literal ASCII space. Tile `(tx, ty)` is centered at pixel
`Vector2(tx * 32 + 16, ty * 32 + 16)`.

A placement is `{ "kind": String, "id": String, "tx": int, "ty": int }`.
`player_spawn` omits `id`. Supported kinds and ids are:

- `player_spawn` — one walkable arrival point
- `npc` — an `NpcDef.id`
- `exit` — the target `AreaDef.id`
- `fight` — an `EncounterDef.id` (currently `enc_road`)
- `ruin` — `ruin_confrontation`
- `shrine` — `shrine_d`

Keep placements on walkable ground, adjacent to rather than inside solid overlay
objects. Every required interaction and exit should be reachable from the spawn.
Enclose map edges with solid scenery unless an authored composition deliberately
needs an open view; the renderer also supplies an invisible outer boundary.

## Tile vocabulary

This table mirrors `tile_vocabulary.gd`, the runtime source of truth. `solid`
tiles receive full 32×32 collision from `TilesetBuilder`.

| Char | Semantic | Atlas `(col,row)` | Solid |
|---|---|---:|:---:|
| `.` | grass | (0,0) | no |
| `,` | grass_flowers | (1,0) | no |
| `=` | path | (2,0) | no |
| `^` | path_edge_n | (3,0) | no |
| `>` | path_edge_e | (4,0) | no |
| `v` | path_edge_s | (5,0) | no |
| `<` | path_edge_w | (6,0) | no |
| `:` | dirt | (7,0) | no |
| `~` | water | (0,1) | **yes** |
| `w` | water_shore | (1,1) | no |
| `_` | floor_wood | (2,2) | no |
| `%` | floor_stone | (3,2) | no |
| `b` | bridge_plank | (6,2) | no |
| `+` | stone_steps | (5,3) | no |
| `m` | mud | (1,3) | no |
| `T` | tree | (2,1) | **yes** |
| `B` | bush | (4,1) | **yes** |
| `r` | rock | (5,1) | **yes** |
| `O` | boulder | (6,1) | **yes** |
| `#` | stone_wall | (7,1) | **yes** |
| `W` | wall_top | (0,2) | no |
| `x` | rubble | (1,2) | no |
| `D` | door | (4,2) | no |
| `f` | fence | (5,2) | **yes** |
| `S` | shrine_stone | (7,2) | **yes** |
| `t` | stump | (4,3) | **yes** |
| `!` | signpost | (7,3) | no |
| `*` | flower_patch | (6,3) | no |
| `'` | grass_tuft | (3,3) | no |
| `l` | water_lily | (0,3) | no |

Do not add a second mapping in generator or renderer code. Extend
`TileVocabulary.TILES` and this reference together.

## Character sheets

Character textures are 256×256 sheets of 64 px frames: **4 walk columns × 4
direction rows**, ordered **DOWN, LEFT, RIGHT, UP**. The first down frame is a
valid static NPC pose. Runtime names are `char_<role>.png` (for example an NPC id
`reeve_f` resolves to `char_reeve.png`).

## Generator checklist

1. Choose an `id` matching an existing area definition.
2. Emit equal-size rectangular ground and overlay grids using only the table.
3. Leave spaces—not dots—in empty overlay cells.
4. Add exactly one walkable `player_spawn` and all story-required placements.
5. Ensure solid tiles do not seal spawn-to-placement routes.
6. Save as `game/data/content/maps/<id>.tres` with `site_map.gd` as its script.
