class_name SceneManager
extends Node
## Complete demo router. It owns presentation modes while GameState remains the
## sole owner of run rules and mutation.

enum Screen { TITLE, OPENING, OVERWORLD, COMBAT, ENDING, GAME_OVER }

var db: ContentDB
var gs: GameState = null
var screen := Screen.TITLE

var world: WorldView = null
var ui_layer: CanvasLayer
var dialogue: DialoguePanel = null
var party_panel: PartyPanel = null
var log_panel: EventLogPanel = null
var debug_overlay: DebugOverlay = null
var combat_screen: CombatScreen = null

var _mode_root: Node
var _flow_host: Control
var _transition: Transition
var _hints: InputHints
var _ui_sounds: UiSounds
var _interaction_hint: Label = null
var _active_encounter_id := ""
var _transitioning := false
var _first_spawn_hint_shown := false


func _ready() -> void:
	db = ContentDB.new()
	_flow_host = Control.new()
	_flow_host.name = "FlowHost"
	_flow_host.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_flow_host.size = get_viewport().get_visible_rect().size
	get_viewport().size_changed.connect(_fit_flow_host)
	add_child(_flow_host)
	_hints = InputHints.new()
	add_child(_hints)
	_ui_sounds = UiSounds.new()
	add_child(_ui_sounds)
	_transition = Transition.new()
	add_child(_transition)
	_show_title(false)


func _fit_flow_host() -> void:
	_flow_host.size = get_viewport().get_visible_rect().size


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_ui_sounds.play_cancel()
	elif event.is_action_pressed("ui_accept"):
		_ui_sounds.play_confirm()


func _unhandled_input(event: InputEvent) -> void:
	if screen == Screen.OVERWORLD:
		if event.is_action_pressed("toggle_log") and log_panel != null:
			log_panel.toggle()
		elif event.is_action_pressed("toggle_debug") and debug_overlay != null:
			debug_overlay.toggle()
	# Combat creates fresh command buttons each turn. Always give keyboard and
	# controller users a focus entry point without coupling to combat rules.
	if screen == Screen.COMBAT and event.is_action_pressed("ui_accept") \
			and get_viewport().gui_get_focus_owner() == null:
		_focus_first_button(combat_screen)
	elif screen == Screen.COMBAT and event.is_action_pressed("ui_cancel") \
			and combat_screen != null and not combat_screen._pending_command.is_empty():
		combat_screen._pending_command.clear()
		combat_screen._offer_commands(combat_screen.combat.current())
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if screen == Screen.COMBAT:
		if get_viewport().gui_get_focus_owner() == null:
			_focus_first_button(combat_screen)
		return
	if screen != Screen.OVERWORLD or world == null or world.player == null or dialogue == null:
		return
	if _interaction_hint != null:
		var nearby = world.player.nearby
		_interaction_hint.text = ("[%s] %s" % [_hints.confirm_label(), nearby.prompt]
				if nearby != null and not dialogue.visible else "")


## --- Screen routing ---------------------------------------------------------

func _show_title(with_fade: bool = true) -> void:
	if with_fade:
		await _begin_transition()
	_clear_mode()
	screen = Screen.TITLE
	var title := FlowScreen.new()
	_mode_root = title
	_flow_host.add_child(title)
	title.selected.connect(_on_title_selected)
	title.setup("<living rpg — demo>",
			["A living story begins with the road ahead."],
			[{"label": "New Game", "id": "new"}, {"label": "Quit", "id": "quit"}])
	if with_fade:
		await _end_transition()


func _on_title_selected(action: String) -> void:
	if action == "new":
		_show_opening()
	elif action == "quit":
		get_tree().quit()


func _show_opening() -> void:
	await _begin_transition()
	_clear_mode()
	screen = Screen.OPENING
	var opening := FlowScreen.new()
	_mode_root = opening
	_flow_host.add_child(opening)
	opening.selected.connect(func(_action: String) -> void: _begin_new_run())
	opening.setup("The troubled road", [
		"You are no novice. Years on the road have sharpened your first technique.",
		"Now you arrive at <hub A>, where an old watch has broken and trade has slowed.",
		"The people here need an adventurer who can choose more than how to fight.",
	], [{"label": "Enter <hub A>", "id": "continue"}])
	await _end_transition()


func _begin_new_run() -> void:
	gs = GameState.new(db, int(Time.get_unix_time_from_system()) % 1000000)
	gs.start_new_run("hub_a")
	_first_spawn_hint_shown = false
	_show_overworld()


func _retry_run() -> void:
	_begin_new_run()


func _show_overworld() -> void:
	await _begin_transition()
	_clear_mode()
	screen = Screen.OVERWORLD
	_mode_root = Node.new()
	add_child(_mode_root)
	world = WorldView.new()
	_mode_root.add_child(world)
	world.interacted.connect(_on_interacted)

	ui_layer = CanvasLayer.new()
	_mode_root.add_child(ui_layer)
	party_panel = PartyPanel.new()
	party_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	party_panel.offset_left = -310
	party_panel.offset_right = -20
	party_panel.offset_top = 20
	ui_layer.add_child(party_panel)

	dialogue = DialoguePanel.new()
	dialogue.choice_made.connect(_on_choice)
	ui_layer.add_child(dialogue)
	dialogue.attach_hints(_hints)

	_interaction_hint = Label.new()
	_interaction_hint.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_interaction_hint.offset_left = 28
	_interaction_hint.offset_top = -48
	_interaction_hint.offset_right = 800
	_interaction_hint.offset_bottom = -16
	_interaction_hint.add_theme_font_size_override("font_size", 21)
	ui_layer.add_child(_interaction_hint)

	log_panel = EventLogPanel.new()
	log_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	log_panel.offset_left = 12
	log_panel.offset_top = -352
	log_panel.offset_bottom = -32
	ui_layer.add_child(log_panel)
	log_panel.attach(gs.event_log)
	debug_overlay = DebugOverlay.new()
	debug_overlay.set_anchors_preset(Control.PRESET_TOP_LEFT)
	debug_overlay.position = Vector2(12, 48)
	ui_layer.add_child(debug_overlay)
	debug_overlay.attach(gs)

	gs.event_log.event_appended.connect(func(_event: Dictionary) -> void:
		if party_panel != null:
			party_panel.refresh(gs))
	_rebuild_world()
	party_panel.refresh(gs)
	await _end_transition()
	if not _first_spawn_hint_shown:
		_first_spawn_hint_shown = true
		_show_first_spawn_hint()


func _show_ending() -> void:
	await _begin_transition()
	var resolution := "You settled the trouble at the ruin."
	if gs.flag("quest_a_resolved_combat"):
		resolution = "You fought the band."
	elif gs.flag("quest_a_resolved_talk"):
		resolution = "You reinstated the watch."
	elif gs.flag("quest_a_resolved_expose"):
		resolution = "You exposed the charter."
	_clear_mode()
	screen = Screen.ENDING
	var ending := FlowScreen.new()
	_mode_root = ending
	_flow_host.add_child(ending)
	ending.selected.connect(func(_action: String) -> void: _show_title())
	ending.setup("Demo complete", [resolution, "The marshal's unanswered offer points down another road."],
			[{"label": "Return to Title", "id": "title"}])
	await _end_transition()


func _show_game_over() -> void:
	await _begin_transition()
	_clear_mode()
	screen = Screen.GAME_OVER
	var game_over := FlowScreen.new()
	_mode_root = game_over
	_flow_host.add_child(game_over)
	game_over.selected.connect(func(action: String) -> void:
		if action == "retry":
			_retry_run()
		else:
			_show_title())
	game_over.setup("The party has fallen", ["The road grows quiet, but this need not be the final telling."], [
		{"label": "Return to Title", "id": "title"},
		{"label": "Retry from <hub A>", "id": "retry"},
	])
	await _end_transition()


## --- Overworld and dialogue -------------------------------------------------

func _on_interacted(kind: String, target_id: String) -> void:
	if dialogue.visible or combat_screen != null or _transitioning:
		return
	match kind:
		"exit":
			await _begin_transition()
			var result := gs.move_to_area(target_id)
			if bool(result.ok):
				_rebuild_world()
			else:
				_open_message("The road is closed", String(result.error))
			await _end_transition()
		"npc":
			_open_dialogue(DialogueData.for_npc(target_id, gs))
		"shrine":
			_open_dialogue(DialogueData.shrine(gs))
		"ruin":
			_open_dialogue(DialogueData.ruin(gs))
		"fight":
			if gs.can_fight(target_id):
				_start_combat(target_id)


func _on_choice(action: String, args: Dictionary) -> void:
	match action:
		"close":
			_close_dialogue()
		"learn_and_start_quest":
			gs.set_flag("quest_a_started", true)
			gs.event_log.append("quest_started", "<elder A> asked the party to uncover why the watch at <ruin C> broke.", {"quest_id": "quest_a"})
			_open_message("Task begun", "Learn why the watch at <ruin C> broke.")
		"learn_technique_c":
			_show_result(gs.learn_technique("player", "technique_c"), "Learned <technique C; guard stance>.")
		"learn_technique_d":
			_show_result(gs.receive_mentor_lesson(), "Learned <technique D>.")
		"buy_item":
			var item_id := String(args.item_id)
			var result := gs.buy(item_id)
			if result.ok:
				_ui_sounds.play_purchase()
			_show_result(result, "Bought %s." % db.item(item_id).display_name)
		"choose_spirit":
			var spirit_id := String(args.spirit_id)
			var result := gs.contract_spirit(spirit_id)
			if result.ok:
				_rebuild_world()
			_show_result(result, "%s joins the party." % db.spirit(spirit_id).display_name)
		"fight_encounter":
			_close_dialogue()
			_start_combat(String(args.encounter_id))
		"negotiate_ruin":
			var result := gs.reinstate_road_watch()
			_rebuild_world()
			_show_result(result, "The band resumes the road watch.")
		"take_charter":
			var result := gs.take_charter()
			_rebuild_world()
			_show_result(result, "The band stands down. Take the charter to <reeve F>.")
		"expose_charter":
			var before := gs.gold
			var result := gs.expose_charter()
			_rebuild_world()
			_show_result(result, "The charter is exposed. Received %d gold." % (gs.gold - before))
		"see_marshal_offer":
			var result := gs.see_marshal_offer()
			if result.ok:
				_close_dialogue()
				_show_ending()
			else:
				_show_result(result, "")
		_:
			push_warning("Unknown dialogue action: %s" % action)
			_close_dialogue()


func _open_dialogue(prompt: Dictionary) -> void:
	world.process_mode = Node.PROCESS_MODE_DISABLED
	dialogue.open(prompt)


func _close_dialogue() -> void:
	dialogue.close()
	world.process_mode = Node.PROCESS_MODE_INHERIT


func _open_message(title: String, text: String) -> void:
	_open_dialogue({"title": title, "lines": [text], "choices": [{"label": "Continue", "action": "close", "args": {}}]})


func _show_result(result: Dictionary, success: String) -> void:
	if not bool(result.ok):
		_ui_sounds.play_error()
	_open_message("", success if bool(result.ok) else String(result.error))


## --- Combat ----------------------------------------------------------------

func _start_combat(encounter_id: String) -> void:
	_active_encounter_id = encounter_id
	_close_dialogue()
	screen = Screen.COMBAT
	world.process_mode = Node.PROCESS_MODE_DISABLED
	world.hide()
	party_panel.hide()
	_interaction_hint.hide()
	var encounter := db.encounter(encounter_id)
	var combat := CombatState.new(db, gs.rng, gs.event_log, encounter, gs.party)
	combat_screen = CombatScreen.new()
	ui_layer.add_child(combat_screen)
	combat_screen.finished.connect(_on_combat_finished)
	combat_screen.start(combat, encounter.intro_text)


func _on_combat_finished(outcome: int) -> void:
	combat_screen.queue_free()
	combat_screen = null
	if outcome == CombatState.Outcome.VICTORY:
		gs.apply_combat_outcome(_active_encounter_id, true)
	elif outcome == CombatState.Outcome.DEFEAT:
		gs.apply_combat_outcome(_active_encounter_id, false)
		_active_encounter_id = ""
		_show_game_over()
		return
	_active_encounter_id = ""
	screen = Screen.OVERWORLD
	world.process_mode = Node.PROCESS_MODE_INHERIT
	world.show()
	party_panel.show()
	_interaction_hint.show()
	_rebuild_world()
	party_panel.refresh(gs)


## --- Helpers ----------------------------------------------------------------

func _rebuild_world() -> void:
	world.build(db.area(gs.current_area_id), db, gs)
	# WorldView's legacy prompt remains part of its contract; the router renders
	# the device-aware version instead.
	await get_tree().process_frame
	if world != null and is_instance_valid(world._prompt):
		world._prompt.hide()


func _show_first_spawn_hint() -> void:
	var hint := Label.new()
	hint.text = "%s to move   %s to interact" % [_hints.movement_label(), _hints.confirm_label()]
	hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_bottom = -76
	hint.offset_top = -112
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 20)
	ui_layer.add_child(hint)
	var tween := create_tween()
	tween.tween_interval(3.0)
	tween.tween_property(hint, "modulate:a", 0.0, 0.5)
	tween.tween_callback(hint.queue_free)


func _focus_first_button(root: Node) -> void:
	if root == null:
		return
	for child in root.get_children():
		if child is Button and not child.disabled:
			child.grab_focus()
			return
		_focus_first_button(child)
		if get_viewport().gui_get_focus_owner() != null:
			return


func _begin_transition() -> void:
	if _transitioning:
		return
	_transitioning = true
	await _transition.fade_out()


func _end_transition() -> void:
	await _transition.fade_in()
	_transitioning = false


func _clear_mode() -> void:
	if _mode_root != null:
		_mode_root.queue_free()
		_mode_root = null
	world = null
	dialogue = null
	party_panel = null
	log_panel = null
	debug_overlay = null
	combat_screen = null
	_interaction_hint = null
