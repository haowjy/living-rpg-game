class_name NpcBody
extends CharacterBody2D
## Validating presentation body for NPC-brain commands. Navigation remains
## ordinary CharacterBody2D physics, so commands cannot bypass map collision.

signal wants_dialogue(npc_id: String)
signal command_finished

const MOVE_SPEED := 92.0
const ARRIVAL_DISTANCE := 5.0
const APPROACH_DISTANCE := 48.0

var npc_id := ""
var dialogue_allowed: Callable

var _destination := Vector2.ZERO
var _approach_target: Node2D = null
var _moving := false
var _approaching := false
var _visual: PaperDollCharacter
var _stalled_time := 0.0


func setup(p_npc_id: String, texture: Texture2D, fallback_tint: Color) -> void:
	npc_id = p_npc_id
	_visual = PaperDollCharacter.new()
	_visual.name = "PaperDollCharacter"
	add_child(_visual)

	var sprite := Sprite2D.new()
	sprite.name = "Character"
	sprite.texture = texture
	sprite.hframes = 4 if texture != null else 1
	sprite.vframes = 4 if texture != null else 1
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position.y = -10.0
	sprite.scale = Vector2(0.72, 0.72)
	if texture == null:
		sprite.modulate = fallback_tint
	_visual.add_child(sprite)
	if texture == null:
		var fallback := Polygon2D.new()
		fallback.name = "FallbackCharacter"
		fallback.polygon = PackedVector2Array([
			Vector2(-13, -28), Vector2(13, -28), Vector2(16, 10),
			Vector2(9, 24), Vector2(-9, 24), Vector2(-16, 10),
		])
		fallback.color = fallback_tint
		fallback.position.y = -10.0
		_visual.add_child(fallback)

	var collision := CollisionShape2D.new()
	var body_shape := RectangleShape2D.new()
	body_shape.size = Vector2(26, 34)
	collision.shape = body_shape
	add_child(collision)


## Walk toward a world-space point until close enough or blocked by collision.
func move_to(world_pos: Vector2) -> void:
	_destination = world_pos
	_approach_target = null
	_approaching = false
	_moving = true
	_stalled_time = 0.0


## Face a cardinal direction and stand on the idle frame.
func face(direction: Vector2) -> void:
	if _visual != null:
		_visual.face(direction)


## Follow a live target, stopping outside conversational distance.
func approach(target_node: Node2D) -> void:
	if not is_instance_valid(target_node):
		idle()
		return
	_approach_target = target_node
	_approaching = true
	_moving = true
	_stalled_time = 0.0


## Request dialogue only when the host presentation reports that it is free.
## Returns false so a brain can wait or abort without repeatedly forcing UI.
func initiate_dialogue() -> bool:
	if dialogue_allowed.is_valid() and not bool(dialogue_allowed.call()):
		return false
	wants_dialogue.emit(npc_id)
	return true


func idle() -> void:
	_moving = false
	_approaching = false
	_approach_target = null
	velocity = Vector2.ZERO
	if _visual != null:
		_visual.set_motion(Vector2.ZERO)


func _physics_process(delta: float) -> void:
	if not _moving:
		return
	if _approaching:
		if not is_instance_valid(_approach_target):
			_finish_command()
			return
		_destination = _approach_target.global_position
	var offset := _destination - global_position
	var stop_distance := APPROACH_DISTANCE if _approaching else ARRIVAL_DISTANCE
	if offset.length() <= stop_distance:
		face(offset)
		_finish_command()
		return
	velocity = offset.normalized() * MOVE_SPEED
	_visual.set_motion(velocity)
	var previous_position := global_position
	move_and_slide()
	if global_position.distance_squared_to(previous_position) < 0.01:
		_stalled_time += delta
		if _stalled_time >= 1.0:
			_finish_command()
	else:
		_stalled_time = 0.0


func _finish_command() -> void:
	idle()
	command_finished.emit()
