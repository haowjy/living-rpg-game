class_name CombatScreen
extends Control
## Composed battle presentation. Drives CombatState exclusively through its
## public command/event surface and turns those events into paced feedback.

signal finished(outcome: int)

enum Phase { COMMAND, TARGETING, RESOLVING, OUTCOME }

const PANEL := preload("res://game/assets/generated/ui/panel.png")
const CURSOR := preload("res://game/assets/generated/ui/cursor.png")
const ENEMY_INTENT_DELAY := 0.62
const EVENT_BEAT := 0.18

var combat: CombatState
var _pending_command: Dictionary = {}
var _cards: Dictionary = {}
var _targets: Array[Combatant] = []
var _target_index := 0
var _phase := Phase.RESOLVING
var _driving := false

var _shake_layer: Control
var _title: Label
var _round_label: Label
var _turn_order: Label
var _message: Label
var _hint: Label
var _enemies_row: HBoxContainer
var _party_row: HBoxContainer
var _actions: GridContainer
var _target_cursor: TextureRect
var _outcome_overlay: Control


func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	# Main mounts presentation controls directly under a CanvasLayer, which has
	# no Control rect for anchors to inherit. Size against the viewport instead.
	size = get_viewport_rect().size
	get_viewport().size_changed.connect(_fit_viewport)
	_build_scene()


func _fit_viewport() -> void:
	size = get_viewport_rect().size


func start(p_combat: CombatState, intro_text: String) -> void:
	combat = p_combat
	_title.text = "BATTLE"
	_message.text = intro_text
	_build_combatant_cards()
	_refresh()
	_drive()


func _unhandled_input(event: InputEvent) -> void:
	if _phase == Phase.OUTCOME and event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_phase = Phase.RESOLVING
		finished.emit(combat.outcome)
		return
	if _phase == Phase.COMMAND and event.is_action_pressed("ui_accept") \
			and get_viewport().gui_get_focus_owner() == null:
		_focus_first_action()
		get_viewport().set_input_as_handled()
		return
	if _phase != Phase.TARGETING:
		return
	if event.is_action_pressed("ui_left"):
		_target_index = wrapi(_target_index - 1, 0, _targets.size())
		_update_target_cursor()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		_target_index = wrapi(_target_index + 1, 0, _targets.size())
		_update_target_cursor()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_confirm_target()
	elif event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_cancel_targeting()


## --- Turn driver ------------------------------------------------------------

func _drive() -> void:
	if _driving:
		return
	_phase = Phase.RESOLVING
	_driving = true
	while combat != null:
		if combat.is_over():
			_driving = false
			_show_outcome()
			return
		var events := combat.begin_turn()
		await _play_events(events)
		if combat.is_over():
			_driving = false
			_show_outcome()
			return
		if combat.turn_consumed:
			continue
		var current := combat.current()
		_refresh()
		if current.is_enemy:
			_clear_actions()
			_hint.text = "ENEMY INTENT"
			_message.text = "%s readies an attack…" % current.display_name
			await get_tree().create_timer(ENEMY_INTENT_DELAY).timeout
			await _play_events(combat.enemy_act())
			continue
		_driving = false
		_offer_commands(current)
		return
	_driving = false


func _offer_commands(current: Combatant) -> void:
	_phase = Phase.COMMAND
	_pending_command.clear()
	_target_cursor.hide()
	_hint.text = "%s'S TURN  ·  CHOOSE AN ACTION" % current.display_name.to_upper()
	_message.text = "What will %s do?" % current.display_name
	_clear_actions()
	var first_button: Button = null
	for command in combat.available_commands():
		var button := Button.new()
		button.text = String(command["label"])
		button.custom_minimum_size = Vector2(178, 44)
		button.focus_mode = Control.FOCUS_ALL
		button.add_theme_font_size_override("font_size", 16)
		_style_action_button(button)
		if command.has("affordable") and not bool(command["affordable"]):
			button.disabled = true
		var captured := command.duplicate()
		button.pressed.connect(func() -> void: _on_command(captured))
		_actions.add_child(button)
		if first_button == null and not button.disabled:
			first_button = button
	if first_button != null:
		first_button.call_deferred("grab_focus")


func _focus_first_action() -> void:
	for child in _actions.get_children():
		if child is Button and not child.disabled:
			child.grab_focus()
			return


func _on_command(command: Dictionary) -> void:
	var kind := String(command["kind"])
	match kind:
		"attack", "technique":
			_pending_command = {"kind": kind}
			if kind == "technique":
				_pending_command["technique_id"] = String(command["technique_id"])
			_enter_targeting()
		"invoke", "guard", "flee":
			_submit({"kind": kind})


func _enter_targeting() -> void:
	_targets.clear()
	for enemy in combat.enemies.filter(func(c: Combatant) -> bool: return c.is_alive()):
		_targets.append(enemy)
	if _targets.is_empty():
		return
	_clear_actions()
	_phase = Phase.TARGETING
	_target_index = 0
	_hint.text = "SELECT TARGET  ·  ◀ ▶ MOVE  ·  CONFIRM  ·  CANCEL"
	_message.text = "Choose an enemy."
	_target_cursor.show()
	await get_tree().process_frame
	_update_target_cursor()


func _confirm_target() -> void:
	if _phase != Phase.TARGETING or _targets.is_empty():
		return
	var command := _pending_command.duplicate()
	_pending_command.clear()
	command["target_id"] = _targets[_target_index].id
	_phase = Phase.RESOLVING
	_target_cursor.hide()
	_submit(command)


func _cancel_targeting() -> void:
	if _phase != Phase.TARGETING:
		return
	_target_cursor.hide()
	_pending_command.clear()
	_offer_commands(combat.current())


func _submit(command: Dictionary) -> void:
	_phase = Phase.RESOLVING
	_pending_command.clear()
	_clear_actions()
	_hint.text = "RESOLVING…"
	var events := combat.perform(command)
	await _play_events(events)
	if not combat.is_over() and not events.is_empty() \
			and String(events[0]["type"]) == "command_rejected":
		_offer_commands(combat.current())
		return
	_drive()


## --- Event presentation -----------------------------------------------------

func _play_events(events: Array[Dictionary]) -> void:
	for event in events:
		_message.text = String(event.get("summary", ""))
		_refresh()
		var event_type := String(event.get("type", ""))
		var data: Dictionary = event.get("data", {})
		if event_type in ["damage_dealt", "technique_used", "burn_tick"] \
				and int(data.get("amount", 0)) > 0:
			await _play_hit(String(data.get("target_id", "")), int(data["amount"]), false)
		elif event_type == "break_triggered":
			await _play_emphasis(String(data.get("target_id", "")), "BREAK!", Color("f0b35b"), 2)
		elif event_type == "actor_downed":
			await _play_emphasis(String(data.get("actor_id", "")), "DOWN", Color("ef6461"), 3)
		elif event_type == "status_applied":
			await _pulse_card(String(data.get("target_id", "")), _status_color(String(data.get("status", ""))))
		await get_tree().create_timer(EVENT_BEAT).timeout
	_refresh()


func _play_hit(target_id: String, amount: int, force_heavy: bool) -> void:
	var card := _card_for(target_id)
	if card == null:
		return
	var max_hp: int = maxi(1, card.combatant.max_hp)
	var ratio := float(amount) / float(max_hp)
	var tier := 1
	if ratio >= 0.25:
		tier = 3
	elif ratio >= 0.12:
		tier = 2
	if force_heavy:
		tier = 3
	_spawn_damage_number(card, amount, tier)
	var resting_position := card.sprite.position
	var recoil := Vector2(5.0 if card.combatant.is_enemy else -5.0, 1.0) * tier
	card.sprite.position = resting_position + recoil
	card.sprite.modulate = Color(2.3, 2.3, 2.3, 1.0)
	if tier >= 2:
		await get_tree().create_timer(0.06 if tier == 2 else 0.10).timeout
	var tween := create_tween().set_parallel(true)
	tween.tween_property(card.sprite, "position", resting_position, 0.13).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(card.sprite, "modulate", Color.WHITE, 0.11)
	if tier >= 2:
		await _shake(3.0 if tier == 2 else 6.0, 0.10 if tier == 2 else 0.16)


func _play_emphasis(target_id: String, word: String, color: Color, tier: int) -> void:
	var card := _card_for(target_id)
	if card == null:
		return
	_spawn_floating_text(card.impact_origin(), word, color, 24)
	card.sprite.modulate = Color(2.4, 1.7, 1.2, 1.0)
	await get_tree().create_timer(0.12).timeout
	create_tween().tween_property(card.sprite, "modulate", Color.WHITE, 0.18)
	await _shake(4.0 if tier == 2 else 7.0, 0.16 if tier == 2 else 0.21)


func _pulse_card(target_id: String, color: Color) -> void:
	var card := _card_for(target_id)
	if card == null:
		return
	card.sprite.modulate = color.lightened(0.45)
	create_tween().tween_property(card.sprite, "modulate", Color.WHITE, 0.20)
	await get_tree().create_timer(0.08).timeout


func _spawn_damage_number(card: CombatantCard, amount: int, tier: int) -> void:
	var color := Color("fff0c2") if tier == 1 else Color("ffd16b")
	if tier == 3:
		color = Color("ff765f")
	_spawn_floating_text(card.impact_origin(), "−%d" % amount, color, 18 + tier * 4)


func _spawn_floating_text(origin: Vector2, text: String, color: Color, font_size: int) -> void:
	var number := Label.new()
	number.text = text
	number.position = origin - Vector2(34, 12)
	number.size = Vector2(90, 34)
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	number.add_theme_font_size_override("font_size", font_size)
	number.add_theme_color_override("font_color", color)
	number.add_theme_color_override("font_shadow_color", Color(0.08, 0.05, 0.06, 0.9))
	number.add_theme_constant_override("shadow_offset_x", 2)
	number.add_theme_constant_override("shadow_offset_y", 2)
	number.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shake_layer.add_child(number)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(number, "position:y", number.position.y - 46.0, 0.52).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(number, "modulate:a", 0.0, 0.18).set_delay(0.36)
	tween.chain().tween_callback(number.queue_free)


func _shake(amplitude: float, duration: float) -> void:
	var steps := 6
	for index in range(steps):
		var falloff := 1.0 - float(index) / float(steps)
		var direction := Vector2(-1.0 if index % 2 == 0 else 1.0,
			0.45 if index % 3 == 0 else -0.35)
		_shake_layer.position = direction * amplitude * falloff
		await get_tree().create_timer(duration / float(steps)).timeout
	_shake_layer.position = Vector2.ZERO


## --- Scene composition ------------------------------------------------------

func _build_scene() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color("17141b")
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var glow := ColorRect.new()
	glow.color = Color("27202c")
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.offset_left = 26
	glow.offset_right = -26
	glow.offset_top = 20
	glow.offset_bottom = -20
	add_child(glow)

	_shake_layer = Control.new()
	_shake_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_shake_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_shake_layer)

	var header := _panel(Vector2(38, 28), Vector2(-38, 102))
	_shake_layer.add_child(header)
	_title = Label.new()
	_title.position = Vector2(28, 15)
	_title.add_theme_font_size_override("font_size", 25)
	_title.add_theme_color_override("font_color", Color("f2d58a"))
	header.add_child(_title)
	_round_label = Label.new()
	_round_label.position = Vector2(28, 48)
	_round_label.add_theme_font_size_override("font_size", 14)
	header.add_child(_round_label)
	_turn_order = Label.new()
	_turn_order.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_turn_order.position = Vector2(-650, 20)
	_turn_order.size = Vector2(620, 32)
	_turn_order.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_turn_order.add_theme_font_size_override("font_size", 14)
	_turn_order.add_theme_color_override("font_color", Color("bcb3be"))
	header.add_child(_turn_order)

	var stage := _panel(Vector2(38, 116), Vector2(-38, -224))
	_shake_layer.add_child(stage)
	var stage_wash := ColorRect.new()
	stage_wash.color = Color(0.13, 0.16, 0.18, 0.72)
	stage_wash.position = Vector2(20, 20)
	stage_wash.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage_wash.offset_right = -20
	stage_wash.offset_bottom = -20
	stage_wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(stage_wash)

	_enemies_row = HBoxContainer.new()
	_enemies_row.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_enemies_row.position = Vector2(-760, 32)
	_enemies_row.size = Vector2(724, 190)
	_enemies_row.alignment = BoxContainer.ALIGNMENT_END
	_enemies_row.add_theme_constant_override("separation", 14)
	stage.add_child(_enemies_row)

	_party_row = HBoxContainer.new()
	_party_row.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_party_row.position = Vector2(34, -202)
	_party_row.size = Vector2(760, 182)
	_party_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	_party_row.add_theme_constant_override("separation", 14)
	stage.add_child(_party_row)

	_target_cursor = TextureRect.new()
	_target_cursor.texture = CURSOR
	_target_cursor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_target_cursor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_target_cursor.size = Vector2(32, 32)
	_target_cursor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_target_cursor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_target_cursor.hide()
	_shake_layer.add_child(_target_cursor)

	var footer := _panel(Vector2(38, -210), Vector2(-38, -28))
	_shake_layer.add_child(footer)
	_message = Label.new()
	_message.position = Vector2(24, 18)
	_message.size = Vector2(660, 70)
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.add_theme_font_size_override("font_size", 19)
	_message.add_theme_color_override("font_color", Color("f1e8dc"))
	footer.add_child(_message)
	_hint = Label.new()
	_hint.position = Vector2(24, 112)
	_hint.size = Vector2(660, 30)
	_hint.add_theme_font_size_override("font_size", 12)
	_hint.add_theme_color_override("font_color", Color("9dc2c2"))
	footer.add_child(_hint)
	_actions = GridContainer.new()
	_actions.columns = 3
	_actions.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_actions.position = Vector2(-596, 16)
	_actions.size = Vector2(570, 148)
	_actions.add_theme_constant_override("h_separation", 8)
	_actions.add_theme_constant_override("v_separation", 8)
	footer.add_child(_actions)


func _panel(top_left: Vector2, bottom_right: Vector2) -> NinePatchRect:
	var panel := NinePatchRect.new()
	panel.texture = PANEL
	panel.patch_margin_left = 12
	panel.patch_margin_top = 12
	panel.patch_margin_right = 12
	panel.patch_margin_bottom = 12
	panel.anchor_left = 0.0
	panel.anchor_right = 1.0
	panel.anchor_top = 1.0 if top_left.y < 0.0 else 0.0
	panel.anchor_bottom = 1.0 if bottom_right.y < 0.0 else 0.0
	panel.offset_left = top_left.x
	panel.offset_top = top_left.y
	panel.offset_right = bottom_right.x
	panel.offset_bottom = bottom_right.y
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel


func _build_combatant_cards() -> void:
	_cards.clear()
	for child in _enemies_row.get_children():
		child.queue_free()
	for child in _party_row.get_children():
		child.queue_free()
	for enemy in combat.enemies:
		_add_card(enemy, _enemies_row)
	for member in combat.party:
		_add_card(member, _party_row)


func _add_card(combatant: Combatant, row: HBoxContainer) -> void:
	var card := CombatantCard.new()
	card.setup(combatant)
	row.add_child(card)
	_cards[combatant.id] = card


func _refresh() -> void:
	if combat == null:
		return
	_round_label.text = "ROUND %d" % combat.round_number
	var current: Combatant = null if combat.is_over() else combat.current()
	for card_id in _cards:
		var card: CombatantCard = _cards[card_id]
		card.refresh(current != null and card.combatant == current)
	var names := PackedStringArray()
	if not combat.is_over():
		for offset in range(combat.queue.size()):
			var queued: Combatant = combat.queue[(combat.turn_index + offset) % combat.queue.size()]
			if queued.is_alive():
				names.append(queued.display_name)
			if names.size() == 4:
				break
	_turn_order.text = "TURN  " + "  ›  ".join(names)


func _update_target_cursor() -> void:
	if _phase != Phase.TARGETING or _targets.is_empty():
		return
	var card := _card_for(_targets[_target_index].id)
	if card == null:
		return
	_target_cursor.global_position = card.global_position + Vector2(card.size.x * 0.5 - 16.0, -22.0)
	_message.text = "%s  ·  HP %d / %d" % [card.combatant.display_name,
		card.combatant.hp(), card.combatant.max_hp]


func _card_for(combatant_id: String) -> CombatantCard:
	return _cards.get(combatant_id) as CombatantCard


func _clear_actions() -> void:
	for child in _actions.get_children():
		child.queue_free()


func _style_action_button(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("27242c")
	normal.border_color = Color("6c606b")
	normal.set_border_width_all(2)
	normal.corner_radius_top_left = 3
	normal.corner_radius_top_right = 3
	normal.corner_radius_bottom_left = 3
	normal.corner_radius_bottom_right = 3
	var focused := normal.duplicate()
	focused.bg_color = Color("4a3f43")
	focused.border_color = Color("f1cd75")
	focused.set_border_width_all(3)
	var disabled := normal.duplicate()
	disabled.bg_color = Color("201e24")
	disabled.border_color = Color("433e45")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", focused)
	button.add_theme_stylebox_override("focus", focused)
	button.add_theme_stylebox_override("pressed", focused)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_disabled_color", Color("6f6871"))


func _status_color(status: String) -> Color:
	match status:
		"burn": return Color("e07a32")
		"vulnerable": return Color("9f6ad4")
		"guard": return Color("4f8fc7")
		_: return Color("e4d6bb")


## --- Outcome ----------------------------------------------------------------

func _show_outcome() -> void:
	if _outcome_overlay != null:
		return
	_clear_actions()
	_phase = Phase.OUTCOME
	_pending_command.clear()
	_target_cursor.hide()
	_hint.text = ""
	_outcome_overlay = ColorRect.new()
	_outcome_overlay.color = Color(0.04, 0.03, 0.05, 0.74)
	_outcome_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_outcome_overlay)
	var card := NinePatchRect.new()
	card.texture = PANEL
	card.patch_margin_left = 12
	card.patch_margin_top = 12
	card.patch_margin_right = 12
	card.patch_margin_bottom = 12
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.position = Vector2(-260, -115)
	card.size = Vector2(520, 230)
	_outcome_overlay.add_child(card)
	var heading := Label.new()
	heading.position = Vector2(24, 38)
	heading.size = Vector2(472, 54)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 34)
	heading.add_theme_color_override("font_color", Color("f2d58a"))
	card.add_child(heading)
	var subheading := Label.new()
	subheading.position = Vector2(24, 102)
	subheading.size = Vector2(472, 32)
	subheading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subheading.add_theme_font_size_override("font_size", 16)
	card.add_child(subheading)
	match combat.outcome:
		CombatState.Outcome.VICTORY:
			heading.text = "Victory!"
			subheading.text = "The road is yours — for now."
		CombatState.Outcome.DEFEAT:
			heading.text = "The party has fallen"
			subheading.text = "Their journey ends here."
		CombatState.Outcome.FLED:
			heading.text = "Retreated"
			subheading.text = "The party escapes the battle."
	var prompt := Label.new()
	prompt.position = Vector2(24, 169)
	prompt.size = Vector2(472, 26)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.text = "CONFIRM  ·  CONTINUE"
	prompt.add_theme_font_size_override("font_size", 13)
	prompt.add_theme_color_override("font_color", Color("9dc2c2"))
	card.add_child(prompt)
	await get_tree().create_timer(0.55).timeout
