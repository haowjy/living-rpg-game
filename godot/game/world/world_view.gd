class_name WorldView
extends Node2D
## Builds the walkable placeholder view of the current area from its AreaDef:
## floor, walls, exits, NPCs, and special markers. Emits interactions upward;
## owns no game state.

signal interacted(kind: String, target_id: String)

const AREA_SIZE := Vector2(1440, 900)
const PLAYER_SCENE := preload("res://game/actors/player.tscn")

var player: Player = null
var _prompt: Label = null


func build(area: AreaDef, db: ContentDB, gs: GameState) -> void:
	for child in get_children():
		child.queue_free()

	var floor_rect := ColorRect.new()
	floor_rect.color = area.floor_color
	floor_rect.size = AREA_SIZE
	add_child(floor_rect)

	_add_walls()

	# Exits along the edges: 0 = west, 1 = east, 2 = north, 3 = south.
	var edge_positions: Array[Vector2] = [
		Vector2(70, AREA_SIZE.y / 2.0), Vector2(AREA_SIZE.x - 70, AREA_SIZE.y / 2.0),
		Vector2(AREA_SIZE.x / 2.0, 90), Vector2(AREA_SIZE.x / 2.0, AREA_SIZE.y - 90),
	]
	for i in area.exits.size():
		var exit_id := area.exits[i]
		var exit_def := db.area(exit_id)
		add_child(Interactable.create("exit", exit_id,
				"travel to %s" % exit_def.display_name,
				edge_positions[mini(i, 3)], Color(0.3, 0.35, 0.45),
				"→ %s" % exit_def.display_name, Vector2(52, 52)))

	var npc_x := AREA_SIZE.x / 2.0 - 160.0
	for npc_id in area.npc_ids:
		var npc := db.npc(npc_id)
		add_child(Interactable.create("npc", npc_id, "talk to %s" % npc.display_name,
				Vector2(npc_x, AREA_SIZE.y / 2.0 - 140), npc.body_color,
				"%s\n(%s)" % [npc.display_name, npc.role]))
		npc_x += 160.0

	match area.id:
		"road_b":
			if gs.can_fight(area.encounter_id):
				add_child(Interactable.create("fight", area.encounter_id,
						"face the beasts", Vector2(AREA_SIZE.x / 2.0 + 200, AREA_SIZE.y / 2.0),
						Color(0.55, 0.25, 0.25), "<monster A> pack", Vector2(44, 44)))
		"ruin_c":
			add_child(Interactable.create("ruin", "ruin_confrontation",
					"approach the ruin", Vector2(AREA_SIZE.x / 2.0, AREA_SIZE.y / 2.0 - 120),
					Color(0.45, 0.3, 0.5), "<ruin C> gate", Vector2(64, 48)))
		"shrine_d":
			add_child(Interactable.create("shrine", "shrine_d",
					"approach the altar", Vector2(AREA_SIZE.x / 2.0, AREA_SIZE.y / 2.0 - 120),
					Color(0.3, 0.5, 0.55), "altar", Vector2(48, 56)))

	player = PLAYER_SCENE.instantiate()
	player.position = AREA_SIZE / 2.0 + Vector2(0, 160)
	add_child(player)

	_prompt = Label.new()
	_prompt.position = Vector2(20, AREA_SIZE.y - 40)
	add_child(_prompt)

	var title := Label.new()
	title.text = "%s — %s" % [area.display_name, area.description]
	title.position = Vector2(20, 12)
	add_child(title)


func _process(_delta: float) -> void:
	if player == null or _prompt == null:
		return
	if player.nearby != null:
		_prompt.text = "[E] %s" % player.nearby.prompt
	else:
		_prompt.text = ""


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player != null and player.nearby != null:
		interacted.emit(player.nearby.kind, player.nearby.target_id)


func _add_walls() -> void:
	var walls := StaticBody2D.new()
	var extents := [
		[Vector2(AREA_SIZE.x / 2.0, -10), Vector2(AREA_SIZE.x, 20)],
		[Vector2(AREA_SIZE.x / 2.0, AREA_SIZE.y + 10), Vector2(AREA_SIZE.x, 20)],
		[Vector2(-10, AREA_SIZE.y / 2.0), Vector2(20, AREA_SIZE.y)],
		[Vector2(AREA_SIZE.x + 10, AREA_SIZE.y / 2.0), Vector2(20, AREA_SIZE.y)],
	]
	for pair in extents:
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = pair[1]
		shape.shape = rect
		shape.position = pair[0]
		walls.add_child(shape)
	add_child(walls)
