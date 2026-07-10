class_name TilesetBuilder
extends RefCounted

const TILE_SIZE := 32
const ATLAS_SOURCE_ID := 0
const TILE_TEXTURE := preload("res://game/assets/generated/tiles.png")


static func build() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	tile_set.add_physics_layer()

	var atlas := TileSetAtlasSource.new()
	atlas.texture = TILE_TEXTURE
	atlas.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	tile_set.add_source(atlas, ATLAS_SOURCE_ID)

	var created: Dictionary = {}
	for character: String in TileVocabulary.TILES:
		var entry: Dictionary = TileVocabulary.TILES[character]
		var coordinates: Vector2i = entry.atlas
		if not created.has(coordinates):
			atlas.create_tile(coordinates)
			created[coordinates] = true
		if entry.solid:
			var tile_data := atlas.get_tile_data(coordinates, 0)
			if tile_data.get_collision_polygons_count(0) == 0:
				tile_data.add_collision_polygon(0)
				tile_data.set_collision_polygon_points(0, 0, PackedVector2Array([
					Vector2(-16, -16), Vector2(16, -16),
					Vector2(16, 16), Vector2(-16, 16),
				]))
	return tile_set
