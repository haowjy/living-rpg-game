class_name WorldView
extends Node2D
## Renders an AreaDef from its SiteMap and forwards interactions to Main.

signal interacted(kind: String, target_id: String)

const TILE_SIZE := 32
const PLAYER_SCENE := preload("res://game/actors/player.tscn")
const MAP_DIRECTORY := "res://game/data/content/maps/"
const PROMPT_TEXTURE := preload("res://game/assets/generated/ui/prompt_e.png")
const ENEMY_TEXTURE := preload("res://game/assets/generated/enemy_beast.png")

var player: Player = null
var _elapsed := 0.0
var _active_affordance: Sprite2D = null
var _ambient_bobs: Array[Sprite2D] = []
var _actor_layer: TileMapLayer


func build(area: AreaDef, db: ContentDB, gs: GameState) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_active_affordance = null
	_ambient_bobs.clear()

	y_sort_enabled = true
	var site := _load_site(area.id)
	var map_size := site.size()
	var tile_set := TilesetBuilder.build()

	var ground := TileMapLayer.new()
	ground.name = "Ground"
	ground.tile_set = tile_set
	ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ground.z_index = -100
	ground.y_sort_enabled = false
	add_child(ground)
	_paint_rows(ground, site.ground_rows, false)

	var overlay := TileMapLayer.new()
	overlay.name = "Overlay"
	overlay.tile_set = tile_set
	overlay.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	overlay.z_index = 0
	overlay.y_sort_enabled = true
	# Tile sort points align with actors positioned at tile centers.
	overlay.y_sort_origin = TILE_SIZE / 2
	add_child(overlay)
	_paint_rows(overlay, site.overlay_rows, true)
	_actor_layer = overlay

	var spawn_tile := Vector2i(map_size.x / 2, map_size.y / 2)
	for placement: Dictionary in site.placements:
		if placement.get("kind", "") == "player_spawn":
			spawn_tile = Vector2i(placement.tx, placement.ty)
		else:
			_add_placement(placement, db, gs)

	player = PLAYER_SCENE.instantiate()
	player.position = _tile_center(spawn_tile)
	_actor_layer.add_child(player)
	_start_npc_brains()
	_add_camera(player, map_size)
	_add_boundary(map_size)


func _process(delta: float) -> void:
	if player == null:
		return
	_elapsed += delta
	var next_affordance: Sprite2D = null
	if player.nearby != null:
		next_affordance = player.nearby.get_node_or_null("InteractionAffordance") as Sprite2D
	if next_affordance != _active_affordance:
		if _active_affordance != null:
			_active_affordance.visible = false
		_active_affordance = next_affordance
		if _active_affordance != null:
			_active_affordance.visible = true
	if _active_affordance != null:
		_active_affordance.position.y = -44.0 + sin(_elapsed * 5.0) * 3.0
		var pulse := 0.82 + sin(_elapsed * 5.0) * 0.12
		_active_affordance.modulate = Color(1.0, 1.0, 1.0, pulse)
	for sprite in _ambient_bobs:
		if is_instance_valid(sprite):
			sprite.position.y = -10.0 + sin(_elapsed * 2.4) * 2.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player != null and player.nearby != null:
		player.face_toward(player.nearby.global_position)
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
			_add_npc(position, target_id, prompt, npc.body_color)
			return
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
	_actor_layer.add_child(node)
	_add_affordance(node)
	if kind == "fight":
		_add_enemy_sprite(node)


func _add_npc(position: Vector2, npc_id: String, prompt: String, color: Color) -> void:
	var path := "res://game/assets/generated/char_%s.png" % npc_id
	if not ResourceLoader.exists(path):
		# Authored NPC ids carry a story suffix (reeve_f); sheets are named for
		# the readable role (char_reeve.png).
		path = "res://game/assets/generated/char_%s.png" % npc_id.get_slice("_", 0)
	var texture: Texture2D = load(path) if ResourceLoader.exists(path) else null
	var body := NpcBody.new()
	body.name = "NPC_%s" % npc_id
	body.position = position
	body.setup(npc_id, texture, color)
	body.dialogue_allowed = _npc_can_initiate_dialogue
	body.wants_dialogue.connect(func(id: String) -> void: interacted.emit("npc", id))
	_actor_layer.add_child(body)

	var interaction := Interactable.create("npc", npc_id, prompt, Vector2.ZERO,
			Color.TRANSPARENT, "", Vector2(34, 38))
	interaction.name = "Interaction"
	for child in interaction.get_children():
		if child is Polygon2D or child is Label:
			child.visible = false
	body.add_child(interaction)
	_add_affordance(interaction)

	var brain := NpcBrain.new()
	brain.name = "Brain"
	body.add_child(brain)
	var points := PackedVector2Array([
		position + Vector2(-TILE_SIZE, 0),
		position,
		position + Vector2(TILE_SIZE, 0),
	])
	# rival_c is the vertical-slice showcase: it approaches the player once,
	# then asks for dialogue through the same interaction signal as manual talk.
	var showcase_target: Node2D = player if npc_id == "rival_c" else null
	# Player is added after placements. Setup showcase brains once build completes.
	brain.set_meta("npc_waypoints", points)
	brain.set_meta("npc_seed", npc_id.hash())
	brain.set_meta("showcase", npc_id == "rival_c")


func _start_npc_brains() -> void:
	for child in _actor_layer.get_children():
		if child is not NpcBody:
			continue
		var body := child as NpcBody
		var brain := body.get_node("Brain") as NpcBrain
		var showcase_target: Node2D = player if bool(brain.get_meta("showcase")) else null
		brain.setup(body, brain.get_meta("npc_waypoints"),
				int(brain.get_meta("npc_seed")), showcase_target)


func _add_enemy_sprite(node: Interactable) -> void:
	for child in node.get_children():
		if child is Polygon2D or child is Label:
			child.visible = false
	var sprite := Sprite2D.new()
	sprite.name = "EnemyBeast"
	sprite.texture = ENEMY_TEXTURE
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(0.72, 0.72)
	sprite.position.y = -10.0
	node.add_child(sprite)
	_ambient_bobs.append(sprite)


func _add_affordance(node: Interactable) -> void:
	var icon := Sprite2D.new()
	icon.name = "InteractionAffordance"
	icon.texture = PROMPT_TEXTURE
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.position.y = -44.0
	icon.scale = Vector2(0.55, 0.55)
	icon.visible = false
	icon.z_index = 20
	node.add_child(icon)


func _npc_can_initiate_dialogue() -> bool:
	var host := get_parent()
	if host == null:
		return false
	var active_dialogue: Variant = host.get("dialogue")
	var active_combat: Variant = host.get("combat_screen")
	return (active_dialogue == null or not active_dialogue.visible) and active_combat == null


func _add_camera(target: Node2D, map_size: Vector2i) -> void:
	var camera := Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = map_size.x * TILE_SIZE
	camera.limit_bottom = map_size.y * TILE_SIZE
	# Zoom far enough that even the compact shop fills the viewport; camera
	# limits alone cannot hide outside space when a map is smaller than view.
	var viewport_size := Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"),
	)
	var pixel_size := Vector2(map_size * TILE_SIZE)
	var minimum_zoom: float = maxf(viewport_size.x / pixel_size.x, viewport_size.y / pixel_size.y)
	var zoom_level: float = maxf(1.25, minimum_zoom)
	camera.zoom = Vector2(zoom_level, zoom_level)
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


func _tile_center(tile: Vector2i) -> Vector2:
	return Vector2(tile * TILE_SIZE) + Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)
