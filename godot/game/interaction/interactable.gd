class_name Interactable
extends Area2D
## A thing in the world the player can interact with (NPC, exit, altar...).
## Carries a kind + id; Main decides what the interaction means.

var kind: String = ""
var target_id: String = ""
var prompt: String = ""


static func create(p_kind: String, p_target_id: String, p_prompt: String,
		p_position: Vector2, p_color: Color, p_label: String,
		p_size: Vector2 = Vector2(36, 36)) -> Interactable:
	var node := Interactable.new()
	node.kind = p_kind
	node.target_id = p_target_id
	node.prompt = p_prompt
	node.position = p_position

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = p_size + Vector2(24, 24)
	shape.shape = rect
	node.add_child(shape)

	var visual := Polygon2D.new()
	var half := p_size / 2.0
	visual.polygon = PackedVector2Array([
		Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
		Vector2(half.x, half.y), Vector2(-half.x, half.y),
	])
	visual.color = p_color
	node.add_child(visual)

	var label := Label.new()
	label.text = p_label
	label.position = Vector2(-half.x - 12, -half.y - 26)
	node.add_child(label)
	return node
