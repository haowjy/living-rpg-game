class_name Player
extends CharacterBody2D
## Overworld player: 8-direction movement plus interactable detection.
## Pure presentation — gameplay consequences go through Main -> GameState.

const MOVE_SPEED := 320.0

## The Interactable currently in range, or null.
var nearby: Interactable = null

@onready var _zone: Area2D = $InteractZone


func _ready() -> void:
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(-14, -18), Vector2(14, -18), Vector2(14, 18), Vector2(-14, 18),
	])
	visual.color = Color(0.85, 0.85, 0.9)
	add_child(visual)
	var label := Label.new()
	label.text = "<player>"
	label.position = Vector2(-32, -42)
	add_child(label)
	_zone.area_entered.connect(_on_zone_changed)
	_zone.area_exited.connect(_on_zone_changed)


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * MOVE_SPEED
	move_and_slide()


func _on_zone_changed(_area: Area2D) -> void:
	nearby = null
	var best_distance := INF
	for area in _zone.get_overlapping_areas():
		if area is Interactable:
			var distance := global_position.distance_squared_to(area.global_position)
			if distance < best_distance:
				best_distance = distance
				nearby = area
