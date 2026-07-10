class_name FlowScreen
extends Control
## Focus-native full-screen card used by the non-gameplay flow screens.

signal selected(action: String)

const PANEL_TEXTURE := preload("res://game/assets/generated/ui/panel.png")

var _committed := false


func setup(heading: String, lines: Array[String], actions: Array[Dictionary]) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("10151c")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 0)
	panel.add_theme_stylebox_override("panel", panel_style())
	center.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	panel.add_child(column)
	var title := Label.new()
	title.text = heading
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	column.add_child(title)
	for line in lines:
		var label := Label.new()
		label.text = line
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 20)
		column.add_child(label)
	for action in actions:
		var button := Button.new()
		button.text = String(action.label)
		var action_id := String(action.id)
		button.pressed.connect(func() -> void:
			if _committed:
				return
			_committed = true
			selected.emit(action_id))
		column.add_child(button)
	if not actions.is_empty():
		await get_tree().process_frame
		var first := column.get_child(column.get_child_count() - actions.size()) as Button
		first.grab_focus()


static func panel_style() -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = PANEL_TEXTURE
	style.texture_margin_left = 12
	style.texture_margin_top = 12
	style.texture_margin_right = 12
	style.texture_margin_bottom = 12
	style.content_margin_left = 28
	style.content_margin_top = 24
	style.content_margin_right = 28
	style.content_margin_bottom = 24
	return style
