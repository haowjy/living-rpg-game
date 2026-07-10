class_name DebugOverlay
extends PanelContainer
## Developer overlay ([F3]): seed, area, flags, recent events.
## Observes state; never owns or mutates it.

var _label: RichTextLabel
var _gs: GameState = null


func _ready() -> void:
	_label = RichTextLabel.new()
	_label.fit_content = true
	_label.custom_minimum_size = Vector2(420, 0)
	add_child(_label)
	hide()


func attach(gs: GameState) -> void:
	_gs = gs


func toggle() -> void:
	visible = not visible


func _process(_delta: float) -> void:
	if not visible or _gs == null:
		return
	var lines := PackedStringArray()
	lines.append("[b]DEBUG[/b]  seed=%d  fps=%d"
			% [_gs.rng.seed_value, Engine.get_frames_per_second()])
	lines.append("area: %s" % _gs.current_area_id)
	lines.append("flags:")
	var flag_names := _gs.flags.keys()
	flag_names.sort()
	for flag_name in flag_names:
		lines.append("  %s = %s" % [flag_name, _gs.flags[flag_name]])
	lines.append("recent events:")
	for event in _gs.event_log.latest(6):
		lines.append("  #%d %s" % [int(event["seq"]), String(event["type"])])
	_label.text = "\n".join(lines)
