class_name PartyPanel
extends PanelContainer
## Compact always-readable overworld HUD.

var _label: RichTextLabel


func _ready() -> void:
	add_theme_stylebox_override("panel", FlowScreen.panel_style())
	_label = RichTextLabel.new()
	_label.fit_content = true
	_label.custom_minimum_size = Vector2(250, 0)
	add_child(_label)


func refresh(gs: GameState) -> void:
	var lines := PackedStringArray()
	lines.append("[b]DAY %d · %s[/b]    ◇ %d gold" % [gs.day, gs.time_of_day_name(), gs.gold])
	for actor in gs.party:
		var line := "[b]%s[/b]  HP %d/%d" % [actor.display_name, actor.hp, actor.max_hp]
		if actor.max_qi > 0 and not actor.is_spirit():
			line += "  Qi %d/%d" % [actor.qi, actor.max_qi]
		if actor.is_spirit():
			var spirit := actor.spirit
			line += "  [%s]" % ("bonded" if spirit.is_bonded()
					else "resting %d" % spirit.rest_remaining)
		lines.append(line)
	_label.text = "\n".join(lines)
