class_name TileVocabulary
extends RefCounted
## The complete authoring vocabulary for SiteMap grids. Keep renderer and
## TileSet construction dependent on this table rather than duplicating it.

const TILES: Dictionary = {
	".": {"semantic": "grass", "atlas": Vector2i(0, 0), "solid": false}, # meadow grass
	",": {"semantic": "grass_flowers", "atlas": Vector2i(1, 0), "solid": false}, # flowering grass
	"=": {"semantic": "path", "atlas": Vector2i(2, 0), "solid": false}, # packed path
	"^": {"semantic": "path_edge_n", "atlas": Vector2i(3, 0), "solid": false}, # north path edge
	">": {"semantic": "path_edge_e", "atlas": Vector2i(4, 0), "solid": false}, # east path edge
	"v": {"semantic": "path_edge_s", "atlas": Vector2i(5, 0), "solid": false}, # south path edge
	"<": {"semantic": "path_edge_w", "atlas": Vector2i(6, 0), "solid": false}, # west path edge
	":": {"semantic": "dirt", "atlas": Vector2i(7, 0), "solid": false}, # bare dirt
	"~": {"semantic": "water", "atlas": Vector2i(0, 1), "solid": true}, # deep water
	"w": {"semantic": "water_shore", "atlas": Vector2i(1, 1), "solid": false}, # shallow shore
	"_": {"semantic": "floor_wood", "atlas": Vector2i(2, 2), "solid": false}, # timber floor
	"%": {"semantic": "floor_stone", "atlas": Vector2i(3, 2), "solid": false}, # dressed-stone floor
	"b": {"semantic": "bridge_plank", "atlas": Vector2i(6, 2), "solid": false}, # bridge deck
	"+": {"semantic": "stone_steps", "atlas": Vector2i(5, 3), "solid": false}, # stone steps
	"m": {"semantic": "mud", "atlas": Vector2i(1, 3), "solid": false}, # wet mud
	"T": {"semantic": "tree", "atlas": Vector2i(2, 1), "solid": true}, # mature tree
	"B": {"semantic": "bush", "atlas": Vector2i(4, 1), "solid": true}, # dense bush
	"r": {"semantic": "rock", "atlas": Vector2i(5, 1), "solid": true}, # rock
	"O": {"semantic": "boulder", "atlas": Vector2i(6, 1), "solid": true}, # boulder
	"#": {"semantic": "stone_wall", "atlas": Vector2i(7, 1), "solid": true}, # stone wall
	"W": {"semantic": "wall_top", "atlas": Vector2i(0, 2), "solid": false}, # wall cap
	"x": {"semantic": "rubble", "atlas": Vector2i(1, 2), "solid": false}, # scattered rubble
	"D": {"semantic": "door", "atlas": Vector2i(4, 2), "solid": false}, # passable door
	"f": {"semantic": "fence", "atlas": Vector2i(5, 2), "solid": true}, # fence
	"S": {"semantic": "shrine_stone", "atlas": Vector2i(7, 2), "solid": true}, # carved shrine stone
	"t": {"semantic": "stump", "atlas": Vector2i(4, 3), "solid": true}, # tree stump
	"!": {"semantic": "signpost", "atlas": Vector2i(7, 3), "solid": false}, # signpost
	"*": {"semantic": "flower_patch", "atlas": Vector2i(6, 3), "solid": false}, # flowers
	"'": {"semantic": "grass_tuft", "atlas": Vector2i(3, 3), "solid": false}, # tall grass tuft
	"l": {"semantic": "water_lily", "atlas": Vector2i(0, 3), "solid": false}, # water lily
	"c": {"semantic": "shop_counter", "atlas": Vector2i(0, 4), "solid": true}, # merchant counter
	"h": {"semantic": "shop_shelf", "atlas": Vector2i(1, 4), "solid": true}, # stocked shelf
	"q": {"semantic": "shop_crate", "atlas": Vector2i(2, 4), "solid": true}, # storage crate
}
