class_name DialoguePanel
extends PanelContainer
## Bottom dialogue box: reveal, advance, then choose. Confirm never fights reveal.

signal choice_made(action: String, args: Dictionary)

const PANEL_TEXTURE := preload("res://game/assets/generated/ui/panel.png")
const FAST_REVEAL := 72.0
const DELIBERATE_REVEAL := 48.0

var _title: Label
var _body: RichTextLabel
var _choices: VBoxContainer
var _hint: Label
var _lines: Array = []
var _line_index := 0
var _reveal_progress := 0.0
var _reveal_speed := FAST_REVEAL
var _prompt: Dictionary = {}
var _input_hints: InputHints


func _ready() -> void:
	set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	offset_left = 72
	offset_right = -72
	offset_top = -310
	offset_bottom = -36
	add_theme_stylebox_override("panel", FlowScreen.panel_style())
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 9)
	add_child(column)
	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 22)
	column.add_child(_title)
	_body = RichTextLabel.new()
	_body.custom_minimum_size = Vector2(0, 72)
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_theme_font_size_override("normal_font_size", 20)
	column.add_child(_body)
	_choices = VBoxContainer.new()
	_choices.add_theme_constant_override("separation", 5)
	column.add_child(_choices)
	_hint = Label.new()
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	column.add_child(_hint)
	hide()


func attach_hints(hints: InputHints) -> void:
	_input_hints = hints
	hints.device_changed.connect(_refresh_hint)


func open(prompt: Dictionary) -> void:
	_prompt = prompt
	_title.text = String(prompt.get("title", ""))
	_lines = prompt.get("lines", [])
	if _lines.is_empty():
		_lines = [""]
	_line_index = 0
	_reveal_speed = DELIBERATE_REVEAL if "shrine" in _title.text.to_lower() or "ceremony" in _title.text.to_lower() else FAST_REVEAL
	for child in _choices.get_children():
		child.queue_free()
	show()
	_show_line()


func close() -> void:
	hide()
	_prompt = {}


func _process(delta: float) -> void:
	if not visible or _body.visible_characters < 0:
		return
	_reveal_progress += delta * _reveal_speed
	_body.visible_characters = mini(int(_reveal_progress), _body.get_total_character_count())
	if _body.visible_characters >= _body.get_total_character_count():
		_body.visible_characters = -1
		_refresh_hint()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if _body.visible_characters >= 0:
			_body.visible_characters = -1
			_refresh_hint()
		elif _choices.get_child_count() == 0:
			_advance()
	elif event.is_action_pressed("ui_cancel") and _body.visible_characters < 0:
		for choice: Dictionary in _prompt.get("choices", []):
			if String(choice.get("action", "")) == "close":
				get_viewport().set_input_as_handled()
				choice_made.emit("close", {})
				return


func _show_line() -> void:
	_body.text = String(_lines[_line_index])
	_body.visible_characters = 0
	_reveal_progress = 0.0
	_hint.text = ""


func _advance() -> void:
	if _line_index + 1 < _lines.size():
		_line_index += 1
		_show_line()
	else:
		_show_choices()


func _show_choices() -> void:
	for choice: Dictionary in _prompt.get("choices", []):
		var button := Button.new()
		button.text = String(choice.get("label", "..."))
		var action := String(choice.get("action", "close"))
		var args: Dictionary = choice.get("args", {})
		button.pressed.connect(func() -> void: choice_made.emit(action, args))
		_choices.add_child(button)
	_refresh_hint()
	await get_tree().process_frame
	if _choices.get_child_count() > 0:
		(_choices.get_child(0) as Button).grab_focus()


func _refresh_hint() -> void:
	if _input_hints == null:
		return
	if _body.visible_characters >= 0:
		_hint.text = "[%s] reveal" % _input_hints.confirm_label()
	elif _choices.get_child_count() == 0:
		_hint.text = "[%s] continue" % _input_hints.confirm_label()
	else:
		_hint.text = "[%s] choose   [%s] back" % [_input_hints.confirm_label(), _input_hints.cancel_label()]
