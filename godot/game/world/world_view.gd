class_name WorldView
extends Node2D
## Renders an AreaDef from its SiteMap and forwards interactions to Main.

signal interacted(kind: String, target_id: String)

const TILE_SIZE := 32
const PLAYER_SCENE := preload("res://game/actors/player.tscn")
const MAP_DIRECTORY := "res://game/data/content/maps/"

var player: Player = null
var _prompt: Label = null


func build(area: AreaDef, db: ContentDB, gs: GameState) -> void:
	for child in get_children():
		child.queue_free()

	y_sort_enabled = true
	var site := _load_site(area.id)
	var map_size := site.size()
	var tile_set := TilesetBuilder.build()

	var ground := TileMapLayer.new()
	ground.name = "Ground"
	ground.tile_set = tile_set
	ground.z_index = -100
	ground.y_sort_enabled = false
	add_child(ground)
	_paint_rows(ground, site.ground_rows, false)

	var overlay := TileMapLayer.new()
	overlay.name = "Overlay"
	overlay.tile_set = tile_set
	overlay.y_sort_enabled = true
	add_child(overlay)
	_paint_rows(overlay, site.overlay_rows, true)

	var spawn_tile := Vector2i(map_size.x / 2, map_size.y / 2)
	for placement: Dictionary in site.placements:
		if placement.get("kind", "") == "player_spawn":
			spawn_tile = Vector2i(placement.tx, placement.ty)
		else:
			_add_placement(placement, db, gs)

	player = PLAYER_SCENE.instantiate()
	player.position = _tile_center(spawn_tile)
	add_child(player)
	_add_camera(player, map_size)
	_add_boundary(map_size)
	_add_prompt()


func _process(_delta: float) -> void:
	if player == null or _prompt == null:
		return
	_prompt.text = "[E] %s" % player.nearby.prompt if player.nearby != null else ""


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player != null and player.nearby != null:
		interacted.emit(player.nearby.kind, player.nearby.target_id)


func _load_site(area_id: String) -> SiteMap:
	var path := "%s%s.tres" % [MAP_DIRECTORY, area_id]
	if ResourceLoader.exists(path):
		var loaded := load(path) as SiteMap
		if loaded != null and not loaded.ground_rows.is_empty():
			return loaded
	push_warning("No valid SiteMap for %s; using grass fallback" % area_id)
	var fallback := SiteMap.new()
	fallback.id = area_id
	var ground := PackedStringArray()
	var overlay := PackedStringArray()
	for y in 24:
		ground.append(".".repeat(40))
		overlay.append(" ".repeat(40))
	fallback.ground_rows = ground
	fallback.overlay_rows = overlay
	fallback.placements = [{"kind": "player_spawn", "tx": 20, "ty": 12}]
	return fallback


func _paint_rows(layer: TileMapLayer, rows: PackedStringArray, allow_empty: bool) -> void:
	for y in rows.size():
		for x in rows[y].length():
			var character := rows[y].substr(x, 1)
			if allow_empty and character == " ":
				continue
			if not TileVocabulary.TILES.has(character):
				push_warning("Unknown map character '%s' at %d,%d" % [character, x, y])
				continue
			var entry: Dictionary = TileVocabulary.TILES[character]
			layer.set_cell(Vector2i(x, y), TilesetBuilder.ATLAS_SOURCE_ID, entry.atlas)


func _add_placement(placement: Dictionary, db: ContentDB, gs: GameState) -> void:
	var kind: String = placement.get("kind", "")
	var target_id: String = placement.get("id", "")
	if kind == "fight" and not gs.can_fight(target_id):
		return
	var position := _tile_center(Vector2i(placement.tx, placement.ty))
	var prompt := "interact"
	var label := ""
	var color := Color(0.35, 0.4, 0.46, 0.85)
	var size := Vector2(36, 36)
	match kind:
		"npc":
			var npc := db.npc(target_id)
			prompt = "talk to %s" % npc.display_name
			label = npc.display_name
			color = npc.body_color
		"exit":
			var destination := db.area(target_id)
			prompt = "travel to %s" % destination.display_name
			label = "→ %s" % destination.display_name
			color = Color(0.25, 0.3, 0.38, 0.55)
		"fight":
			prompt = "face the beasts"
			label = "beast tracks"
			color = Color(0.55, 0.22, 0.2, 0.8)
		"ruin":
			prompt = "approach the ruin"
			label = "ruined gate"
			size = Vector2(56, 44)
		"shrine":
			prompt = "approach the altar"
			label = "altar"
			color = Color(0.3, 0.5, 0.55, 0.75)
	var node := Interactable.create(kind, target_id, prompt, position, color, label, size)
	add_child(node)
	if kind == "npc":
		_add_npc_sprite(node, target_id)


func _add_npc_sprite(node: Interactable, npc_id: String) -> void:
	var path := "res://game/assets/generated/char_%s.png" % npc_id
	if not ResourceLoader.exists(path):
		# Authored NPC ids carry a story suffix (reeve_f); sheets are named for
		# the readable role (char_reeve.png).
		path = "res://game/assets/generated/char_%s.png" % npc_id.get_slice("_", 0)
	if not ResourceLoader.exists(path):
		return
	for child in node.get_children():
		if child is Polygon2D:
			child.visible = false
	var sprite := Sprite2D.new()
	sprite.texture = load(path)
	sprite.hframes = 4
	sprite.vframes = 4
	sprite.frame_coords = Vector2i(0, 0)
	sprite.scale = Vector2(0.72, 0.72)
	sprite.position.y = -10
	node.add_child(sprite)


func _add_camera(target: Node2D, map_size: Vector2i) -> void:
	var camera := Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = map_size.x * TILE_SIZE
	camera.limit_bottom = map_size.y * TILE_SIZE
	camera.limit_smoothed = true
	camera.zoom = Vector2(1.25, 1.25)
	target.add_child(camera)


func _add_boundary(map_size: Vector2i) -> void:
	var bounds := StaticBody2D.new()
	bounds.name = "MapBoundary"
	var pixel_size := Vector2(map_size * TILE_SIZE)
	var segments := [
		[Vector2(pixel_size.x / 2.0, -8), Vector2(pixel_size.x + 32, 16)],
		[Vector2(pixel_size.x / 2.0, pixel_size.y + 8), Vector2(pixel_size.x + 32, 16)],
		[Vector2(-8, pixel_size.y / 2.0), Vector2(16, pixel_size.y)],
		[Vector2(pixel_size.x + 8, pixel_size.y / 2.0), Vector2(16, pixel_size.y)],
	]
	for segment in segments:
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = segment[1]
		shape.position = segment[0]
		shape.shape = rectangle
		bounds.add_child(shape)
	add_child(bounds)


func _add_prompt() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	_prompt = Label.new()
	_prompt.position = Vector2(24, 840)
	_prompt.add_theme_font_size_override("font_size", 22)
	canvas.add_child(_prompt)
	add_child(canvas)


func _tile_center(tile: Vector2i) -> Vector2:
	return Vector2(tile * TILE_SIZE) + Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)
