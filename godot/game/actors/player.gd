class_name Player
extends CharacterBody2D
## Overworld player: free cardinal-facing movement plus interactable detection.
## Pure presentation — gameplay consequences go through Main -> GameState.

const MOVE_SPEED := 176.0

## The Interactable currently in range, or null.
var nearby: Interactable = null

@onready var _zone: Area2D = $InteractZone
@onready var _visual: PaperDollCharacter = $PaperDollCharacter


func _ready() -> void:
	_zone.area_entered.connect(_on_zone_changed)
	_zone.area_exited.connect(_on_zone_changed)


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# Input.get_vector clamps the vector length, so diagonals never move faster.
	velocity = direction * MOVE_SPEED
	_visual.set_motion(direction)
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
