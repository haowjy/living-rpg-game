class_name InputHints
extends Node
## Remembers the most recently used input family so prompts stay truthful.

signal device_changed

var joypad_active := false


func _input(event: InputEvent) -> void:
	var next_is_joypad := joypad_active
	if event is InputEventJoypadButton and event.pressed:
		next_is_joypad = true
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.35:
		next_is_joypad = true
	elif event is InputEventKey and event.pressed:
		next_is_joypad = false
	else:
		return
	if next_is_joypad != joypad_active:
		joypad_active = next_is_joypad
		device_changed.emit()


func confirm_label() -> String:
	return "A" if joypad_active else "Z / E"


func cancel_label() -> String:
	return "B" if joypad_active else "X / Esc"


func movement_label() -> String:
	return "D-pad / stick" if joypad_active else "Arrows / WASD"
