class_name NpcBrain
extends Node
## Replaceable deterministic presentation brain. It knows only NpcBody's
## command socket; a future local oracle can emit the same commands.

enum Mode { PAUSE, WALK, APPROACH, WAIT_TO_TALK, DONE }

const MIN_PAUSE := 1.4
const MAX_PAUSE := 3.6
const APPROACH_TIMEOUT := 12.0
const BUSY_WAIT_TIMEOUT := 6.0

var _body: NpcBody
var _waypoints: PackedVector2Array
var _rng := RandomNumberGenerator.new()
var _mode := Mode.PAUSE
var _timer := 0.0
var _showcase_target: Node2D = null


func setup(body: NpcBody, waypoints: PackedVector2Array, seed: int,
		showcase_target: Node2D = null) -> void:
	_body = body
	_waypoints = waypoints
	_rng.seed = seed
	_showcase_target = showcase_target
	_body.command_finished.connect(_on_command_finished)
	if is_instance_valid(_showcase_target):
		_mode = Mode.APPROACH
		_timer = APPROACH_TIMEOUT
		_body.approach(_showcase_target)
	else:
		_begin_pause()


func _process(delta: float) -> void:
	if _body == null:
		return
	_timer -= delta
	match _mode:
		Mode.PAUSE:
			if _timer <= 0.0:
				_walk_to_next_waypoint()
		Mode.APPROACH:
			if _timer <= 0.0:
				_body.idle()
				_mode = Mode.DONE
		Mode.WAIT_TO_TALK:
			if _body.initiate_dialogue():
				_mode = Mode.DONE
			elif _timer <= 0.0:
				_body.idle()
				_mode = Mode.DONE


func _on_command_finished() -> void:
	match _mode:
		Mode.WALK:
			_begin_pause()
		Mode.APPROACH:
			_mode = Mode.WAIT_TO_TALK
			_timer = BUSY_WAIT_TIMEOUT
			_body.face(_showcase_target.global_position - _body.global_position)


func _begin_pause() -> void:
	_mode = Mode.PAUSE
	_timer = _rng.randf_range(MIN_PAUSE, MAX_PAUSE)
	_body.idle()
	var directions := [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP]
	_body.face(directions[_rng.randi_range(0, directions.size() - 1)])


func _walk_to_next_waypoint() -> void:
	if _waypoints.is_empty():
		_begin_pause()
		return
	_mode = Mode.WALK
	_body.move_to(_waypoints[_rng.randi_range(0, _waypoints.size() - 1)])
