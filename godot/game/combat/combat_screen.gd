class_name CombatScreen
extends Control
## Turn-based battle screen. Pure driver/renderer around CombatState:
## shows state, offers the sim's legal commands, plays enemy turns with a
## short delay, and reports the outcome back to Main.

signal finished(outcome: int)

const ENEMY_TURN_DELAY := 0.55

var combat: CombatState = null
var _pending_command: Dictionary = {}

var _title: Label
var _round_label: Label
var _enemies_row: HBoxContainer
var _party_row: HBoxContainer
var _battle_log: RichTextLabel
var _log_scroll: ScrollContainer
var _actions_row: HBoxContainer
var _hint: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.09, 0.09, 0.12)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_FULL_RECT)
	column.offset_left = 40
	column.offset_right = -40
	column.offset_top = 24
	column.offset_bottom = -24
	column.add_theme_constant_override("separation", 12)
	add_child(column)

	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 22)
	column.add_child(_title)
	_round_label = Label.new()
	column.add_child(_round_label)

	_enemies_row = HBoxContainer.new()
	_enemies_row.add_theme_constant_override("separation", 16)
	column.add_child(_enemies_row)

	_log_scroll = ScrollContainer.new()
	_log_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_log_scroll)
	_battle_log = RichTextLabel.new()
	_battle_log.fit_content = true
	_battle_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_log_scroll.add_child(_battle_log)

	_party_row = HBoxContainer.new()
	_party_row.add_theme_constant_override("separation", 16)
	column.add_child(_party_row)

	_hint = Label.new()
	column.add_child(_hint)
	_actions_row = HBoxContainer.new()
	_actions_row.add_theme_constant_override("separation", 8)
	column.add_child(_actions_row)


func start(p_combat: CombatState, intro_text: String) -> void:
	combat = p_combat
	_title.text = combat.encounter.display_name
	_append_line("[i]%s[/i]" % intro_text)
	_refresh_panels()
	_drive()


## --- Turn driver ------------------------------------------------------------

func _drive() -> void:
	while true:
		if combat.is_over():
			_show_outcome()
			return
		var events := combat.begin_turn()
		_render_events(events)
		if combat.is_over():
			_show_outcome()
			return
		if combat.turn_consumed:
			continue
		var c := combat.current()
		if c.is_enemy:
			_hint.text = "%s's turn..." % c.display_name
			_clear_actions()
			await get_tree().create_timer(ENEMY_TURN_DELAY).timeout
			_render_events(combat.enemy_act())
			continue
		_offer_commands(c)
		return


func _offer_commands(c: Combatant) -> void:
	_hint.text = "%s's turn — choose a command." % c.display_name
	_clear_actions()
	for command in combat.available_commands():
		var button := Button.new()
		button.text = String(command["label"])
		if command.has("affordable") and not bool(command["affordable"]):
			button.disabled = true
		var kind := String(command["kind"])
		button.pressed.connect(func() -> void: _on_command(kind, command))
		_actions_row.add_child(button)


func _on_command(kind: String, command: Dictionary) -> void:
	match kind:
		"attack", "technique":
			_pending_command = {"kind": kind}
			if kind == "technique":
				_pending_command["technique_id"] = String(command["technique_id"])
			_offer_targets()
		"invoke", "guard", "flee":
			_submit({"kind": kind})


func _offer_targets() -> void:
	_hint.text = "Choose a target."
	_clear_actions()
	for enemy in combat._living(combat.enemies):
		var button := Button.new()
		button.text = "%s (%d hp)" % [enemy.display_name, enemy.hp()]
		var enemy_id := enemy.id
		button.pressed.connect(func() -> void:
			var command := _pending_command.duplicate()
			command["target_id"] = enemy_id
			_submit(command))
		_actions_row.add_child(button)
	var cancel := Button.new()
	cancel.text = "Back"
	cancel.pressed.connect(func() -> void: _offer_commands(combat.current()))
	_actions_row.add_child(cancel)


func _submit(command: Dictionary) -> void:
	_clear_actions()
	var events := combat.perform(command)
	_render_events(events)
	# A rejected command does not consume the turn; re-offer it.
	if not combat.is_over() and not events.is_empty() \
			and String(events[0]["type"]) == "command_rejected":
		_offer_commands(combat.current())
		return
	_drive()


## --- Rendering --------------------------------------------------------------

func _render_events(events: Array[Dictionary]) -> void:
	for event in events:
		_append_line(String(event["summary"]))
	_refresh_panels()


func _append_line(text: String) -> void:
	_battle_log.append_text(text + "\n")
	_log_scroll.scroll_vertical = int(_log_scroll.get_v_scroll_bar().max_value)


func _refresh_panels() -> void:
	_round_label.text = "Round %d" % combat.round_number
	_fill_row(_enemies_row, combat.enemies)
	_fill_row(_party_row, combat.party)


func _fill_row(row: HBoxContainer, combatants: Array[Combatant]) -> void:
	for child in row.get_children():
		child.queue_free()
	for c in combatants:
		var panel := PanelContainer.new()
		var label := RichTextLabel.new()
		label.fit_content = true
		label.custom_minimum_size = Vector2(200, 0)
		var lines := PackedStringArray()
		var name_line := "[b]%s[/b]" % c.display_name
		if not c.is_alive():
			name_line += " [color=gray](down)[/color]"
		elif combat.current() == c and not combat.is_over():
			name_line += " [color=yellow]◄[/color]"
		lines.append(name_line)
		lines.append("HP %d/%d" % [c.hp(), c.max_hp])
		if not c.is_enemy and not c.is_spirit():
			lines.append("Qi %d/%d" % [c.qi(), c.actor.max_qi])
		if c.is_spirit():
			lines.append("bond: %s" % ("bonded" if c.actor.spirit.is_bonded()
					else "resting %d" % c.actor.spirit.rest_remaining))
		if c.max_toughness > 0:
			lines.append("break: %s %d/%d" % ["BROKEN" if c.broken else "toughness",
					c.toughness, c.max_toughness])
			lines.append("weak to: %s" % ", ".join(c.weak_tags))
		if not c.statuses.is_empty():
			var status_bits := PackedStringArray()
			for status_name in c.statuses:
				status_bits.append("%s x%d" % [status_name, int(c.statuses[status_name])])
			lines.append("[color=orange]%s[/color]" % ", ".join(status_bits))
		label.text = "\n".join(lines)
		panel.add_child(label)
		row.add_child(panel)


func _clear_actions() -> void:
	for child in _actions_row.get_children():
		child.queue_free()


func _show_outcome() -> void:
	_clear_actions()
	var text := ""
	match combat.outcome:
		CombatState.Outcome.VICTORY:
			text = "Victory."
		CombatState.Outcome.DEFEAT:
			text = "The party has fallen."
		CombatState.Outcome.FLED:
			text = "You fled."
	_hint.text = text
	var button := Button.new()
	button.text = "Continue"
	button.pressed.connect(func() -> void: finished.emit(combat.outcome))
	_actions_row.add_child(button)
