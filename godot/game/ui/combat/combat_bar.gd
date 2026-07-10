class_name CombatBar
extends Control
## Pixel-art framed meter used for combat HP and qi.

const FRAME := preload("res://game/assets/generated/ui/bar_frame.png")
const HP_FILL := preload("res://game/assets/generated/ui/hp_fill.png")
const QI_FILL := preload("res://game/assets/generated/ui/qi_fill.png")

var value: int = 0
var maximum: int = 1
var is_qi: bool = false


func _ready() -> void:
	custom_minimum_size = Vector2(128, 16)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_meter(p_value: int, p_maximum: int, p_is_qi: bool = false) -> void:
	value = p_value
	maximum = maxi(1, p_maximum)
	is_qi = p_is_qi
	queue_redraw()


func _draw() -> void:
	var scale_factor := size.x / 64.0
	var frame_rect := Rect2(Vector2.ZERO, Vector2(size.x, 8.0 * scale_factor))
	var fill_rect := Rect2(
		Vector2(4.0 * scale_factor, 2.0 * scale_factor),
		Vector2(56.0 * scale_factor * clampf(float(value) / float(maximum), 0.0, 1.0),
			4.0 * scale_factor))
	if fill_rect.size.x > 0.0:
		draw_texture_rect(QI_FILL if is_qi else HP_FILL, fill_rect, true)
	draw_texture_rect(FRAME, frame_rect, false)
