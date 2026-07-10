class_name Transition
extends CanvasLayer
## One short, awaitable beat between places and modes.

const DURATION := 0.24

var _veil: ColorRect


func _ready() -> void:
	layer = 100
	_veil = ColorRect.new()
	_veil.color = Color(0.025, 0.03, 0.04, 0.0)
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_veil)


func fade_out() -> void:
	_veil.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_veil, "color:a", 1.0, DURATION)
	await tween.finished


func fade_in() -> void:
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_veil, "color:a", 0.0, DURATION)
	await tween.finished
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
