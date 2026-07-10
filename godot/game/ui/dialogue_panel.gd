class_name DialoguePanel
extends PanelContainer
## Modal dialogue/choice panel. Renders a DialogueData prompt Dictionary
## and emits the chosen action for Main to execute.

signal choice_made(action: String, args: Dictionary)

var _title: Label
var _body: RichTextLabel
var _choices: VBoxContainer


func _ready() -> void:
	custom_minimum_size = Vector2(640, 0)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	add_child(column)
	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 20)
	column.add_child(_title)
	_body = RichTextLabel.new()
	_body.fit_content = true
	_body.custom_minimum_size = Vector2(600, 0)
	column.add_child(_body)
	_choices = VBoxContainer.new()
	_choices.add_theme_constant_override("separation", 6)
	column.add_child(_choices)
	hide()


func open(prompt: Dictionary) -> void:
	_title.text = String(prompt.get("title", ""))
	var lines: Array = prompt.get("lines", [])
	_body.text = "\n".join(PackedStringArray(lines))
	for child in _choices.get_children():
		child.queue_free()
	var choices: Array = prompt.get("choices", [])
	for choice in choices:
		var button := Button.new()
		button.text = String(choice.get("label", "..."))
		var action := String(choice.get("action", "close"))
		var args: Dictionary = choice.get("args", {})
		button.pressed.connect(func() -> void: choice_made.emit(action, args))
		_choices.add_child(button)
	show()


func close() -> void:
	hide()
