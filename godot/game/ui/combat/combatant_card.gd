class_name CombatantCard
extends Control
## One readable battle participant: sprite, meters, turn/down state, and statuses.

const PANEL := preload("res://game/assets/generated/ui/panel.png")
const STATUS_COLORS := {
	"burn": Color("e07a32"),
	"vulnerable": Color("9f6ad4"),
	"guard": Color("4f8fc7"),
}

var combatant: Combatant
var sprite: TextureRect
var _name_label: Label
var _hp_label: Label
var _qi_label: Label
var _hp_bar: CombatBar
var _qi_bar: CombatBar
var _toughness_label: Label
var _toughness_bar: CombatBar
var _weakness_label: Label
var _badges: HBoxContainer
var _turn_marker: Label
var _panel: NinePatchRect


func setup(p_combatant: Combatant) -> void:
	combatant = p_combatant
	custom_minimum_size = Vector2(274, 174)
	_build()
	refresh(false)


func _build() -> void:
	_panel = NinePatchRect.new()
	_panel.texture = PANEL
	_panel.patch_margin_left = 12
	_panel.patch_margin_top = 12
	_panel.patch_margin_right = 12
	_panel.patch_margin_bottom = 12
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)

	_turn_marker = Label.new()
	_turn_marker.text = "TURN"
	_turn_marker.position = Vector2(12, 9)
	_turn_marker.add_theme_color_override("font_color", Color("fff0c2"))
	_turn_marker.add_theme_font_size_override("font_size", 12)
	var marker_chip := StyleBoxFlat.new()
	marker_chip.bg_color = Color("3c333e")
	marker_chip.border_color = Color("c5984c")
	marker_chip.set_border_width_all(1)
	marker_chip.set_content_margin_all(4)
	_turn_marker.add_theme_stylebox_override("normal", marker_chip)
	add_child(_turn_marker)

	sprite = TextureRect.new()
	sprite.texture = CombatPortraitCatalog.resolve(combatant)
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.custom_minimum_size = Vector2(88, 88)
	sprite.position = Vector2(8, 29)
	sprite.size = Vector2(88, 88)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sprite)

	var details := VBoxContainer.new()
	details.position = Vector2(94, 25)
	details.size = Vector2(170, 128)
	details.add_theme_constant_override("separation", 2)
	add_child(details)

	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 16)
	_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	details.add_child(_name_label)

	_hp_label = Label.new()
	_hp_label.add_theme_font_size_override("font_size", 11)
	details.add_child(_hp_label)
	_hp_bar = CombatBar.new()
	details.add_child(_hp_bar)

	_qi_label = Label.new()
	_qi_label.add_theme_font_size_override("font_size", 11)
	details.add_child(_qi_label)
	_qi_bar = CombatBar.new()
	details.add_child(_qi_bar)

	_toughness_label = Label.new()
	_toughness_label.add_theme_font_size_override("font_size", 11)
	details.add_child(_toughness_label)
	_toughness_bar = CombatBar.new()
	details.add_child(_toughness_bar)

	_weakness_label = Label.new()
	_weakness_label.add_theme_font_size_override("font_size", 10)
	_weakness_label.add_theme_color_override("font_color", Color("6f665e"))
	details.add_child(_weakness_label)

	_badges = HBoxContainer.new()
	_badges.add_theme_constant_override("separation", 4)
	details.add_child(_badges)


func refresh(is_current: bool) -> void:
	if combatant == null:
		return
	_turn_marker.visible = is_current and combatant.is_alive()
	_name_label.text = combatant.display_name if combatant.is_alive() else "%s — DOWN" % combatant.display_name
	_name_label.add_theme_color_override("font_color",
		Color.WHITE if combatant.is_alive() else Color("887f83"))
	_hp_label.text = "HP  %d / %d" % [combatant.hp(), combatant.max_hp]
	_hp_bar.set_meter(combatant.hp(), combatant.max_hp)
	var show_qi := not combatant.is_enemy and not combatant.is_spirit() and combatant.actor.max_qi > 0
	_qi_label.visible = show_qi
	_qi_bar.visible = show_qi
	if show_qi:
		_qi_label.text = "QI  %d / %d" % [combatant.qi(), combatant.actor.max_qi]
		_qi_bar.set_meter(combatant.qi(), combatant.actor.max_qi, true)
	var show_break := combatant.is_enemy and combatant.max_toughness > 0
	_toughness_label.visible = show_break
	_toughness_bar.visible = show_break
	_weakness_label.visible = show_break
	if show_break:
		_toughness_label.text = ("BROKEN" if combatant.broken else
				"TOUGHNESS  %d / %d" % [combatant.toughness, combatant.max_toughness])
		_toughness_label.add_theme_color_override("font_color",
				Color("ef6461") if combatant.broken else Color("594c43"))
		_toughness_bar.set_meter(combatant.toughness, combatant.max_toughness)
		var weakness_names: PackedStringArray = []
		for tag in combatant.weak_tags:
			weakness_names.append(String(tag).to_upper())
		_weakness_label.text = "WEAK  %s" % " · ".join(weakness_names)
	_rebuild_badges()
	modulate = Color.WHITE if combatant.is_alive() else Color(0.55, 0.55, 0.58, 0.8)


func impact_origin() -> Vector2:
	return global_position + sprite.position + sprite.size * Vector2(0.5, 0.25)


func _rebuild_badges() -> void:
	for child in _badges.get_children():
		child.queue_free()
	for status_name in ["burn", "vulnerable", "guard"]:
		var stacks := int(combatant.statuses.get(status_name, 0))
		if stacks <= 0:
			continue
		var badge := Label.new()
		badge.text = "%s ×%d" % [String(status_name).to_upper(), stacks]
		badge.add_theme_font_size_override("font_size", 10)
		badge.add_theme_color_override("font_color", STATUS_COLORS[status_name])
		_badges.add_child(badge)
