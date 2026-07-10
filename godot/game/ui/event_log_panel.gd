class_name EventLogPanel
extends PanelContainer
## Toggleable panel ([L]) showing the run's event log — the world's memory,
## rendered straight from EventLog entries.

var _label: RichTextLabel
var _log: EventLog = null


func _ready() -> void:
	custom_minimum_size = Vector2(560, 320)
	var column := VBoxContainer.new()
	add_child(column)
	var title := Label.new()
	title.text = "Event log  [L to close]"
	column.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(540, 280)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	_label = RichTextLabel.new()
	_label.fit_content = true
	_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_label)
	hide()


func attach(p_log: EventLog) -> void:
	_log = p_log
	p_log.event_appended.connect(func(_event: Dictionary) -> void: _refresh())
	_refresh()


func toggle() -> void:
	visible = not visible
	if visible:
		_refresh()


func _refresh() -> void:
	if _log == null:
		return
	var lines := PackedStringArray()
	for event in _log.latest(40):
		lines.append("[color=gray]#%03d[/color] [b]%s[/b]  %s"
				% [int(event["seq"]), String(event["type"]), String(event["summary"])])
	_label.text = "\n".join(lines)
