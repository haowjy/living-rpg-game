class_name PartyPanel
extends PanelContainer
## Always-visible party status: hp/qi, technique proficiency, spirit state.

var _label: RichTextLabel


func _ready() -> void:
	_label = RichTextLabel.new()
	_label.fit_content = true
	_label.custom_minimum_size = Vector2(300, 0)
	add_child(_label)


func refresh(gs: GameState) -> void:
	var lines := PackedStringArray()
	for actor in gs.party:
		var line := "[b]%s[/b]  HP %d/%d" % [actor.display_name, actor.hp, actor.max_hp]
		if actor.max_qi > 0 and not actor.is_spirit():
			line += "  Qi %d/%d" % [actor.qi, actor.max_qi]
		if actor.is_spirit():
			var spirit := actor.spirit
			line += "  [%s]" % ("bonded" if spirit.is_bonded()
					else "resting %d" % spirit.rest_remaining)
		lines.append(line)
		for technique in actor.techniques:
			lines.append("    %s — %s (%d uses)"
					% [technique.def.display_name, technique.level_name(), technique.uses])
	_label.text = "\n".join(lines)
