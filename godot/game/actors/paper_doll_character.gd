class_name PaperDollCharacter
extends Node2D
## Presentation-only layered character visual. All Sprite2D layers share one
## direction row and walk frame so interchangeable art stays synchronized.

enum DirectionRow { DOWN, LEFT, RIGHT, UP }

const WALK_FRAME_COUNT := 4

@export_range(1.0, 30.0, 0.5) var frames_per_second := 8.0

var _direction_row := DirectionRow.DOWN
var _walk_frame := 0
var _frame_time := 0.0
var _is_walking := false


func _ready() -> void:
	_apply_frame()


func _process(delta: float) -> void:
	if not _is_walking:
		return
	_frame_time += delta
	var frame_duration := 1.0 / frames_per_second
	while _frame_time >= frame_duration:
		_frame_time -= frame_duration
		_walk_frame = (_walk_frame + 1) % WALK_FRAME_COUNT
	_apply_frame()


## Updates facing and walking state from presentation movement input.
func set_motion(motion: Vector2) -> void:
	if motion.is_zero_approx():
		_is_walking = false
		_frame_time = 0.0
		_walk_frame = 0
	else:
		if not _is_walking:
			_frame_time = 0.0
			_walk_frame = 0
		_is_walking = true
		_direction_row = _row_for(motion)
	_apply_frame()


## Changes direction immediately without starting the walk cycle.
func face(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return
	_direction_row = _row_for(direction)
	_is_walking = false
	_frame_time = 0.0
	_walk_frame = 0
	_apply_frame()


func _row_for(motion: Vector2) -> DirectionRow:
	if absf(motion.x) > absf(motion.y):
		return DirectionRow.LEFT if motion.x < 0.0 else DirectionRow.RIGHT
	return DirectionRow.UP if motion.y < 0.0 else DirectionRow.DOWN


func _apply_frame() -> void:
	var frame_coords := Vector2i(_walk_frame, _direction_row)
	for child in get_children():
		if child is Sprite2D:
			(child as Sprite2D).frame_coords = frame_coords
