class_name Main
extends Node
## Top-level wiring: owns the GameState, swaps between overworld and combat,
## and executes dialogue actions. All state changes go through GameState;
## this node only orchestrates.

var db: ContentDB
var gs: GameState

var world: WorldView
var ui_layer: CanvasLayer
var dialogue: DialoguePanel
var party_panel: PartyPanel
var log_panel: EventLogPanel
var debug_overlay: DebugOverlay
var toast: Label
var combat_screen: CombatScreen = null
var _active_encounter_id: String = ""


func _ready() -> void:
	db = ContentDB.new()
	gs = GameState.new(db, int(Time.get_unix_time_from_system()) % 1000000)
	gs.start_new_run("hub_a")
	gs.learn_technique("companion_a", "technique_b")

	world = WorldView.new()
	add_child(world)
	world.interacted.connect(_on_interacted)

	ui_layer = CanvasLayer.new()
	add_child(ui_layer)

	party_panel = PartyPanel.new()
	party_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	party_panel.offset_left = -340
	party_panel.offset_right = -12
	party_panel.offset_top = 12
	ui_layer.add_child(party_panel)

	dialogue = DialoguePanel.new()
	dialogue.set_anchors_preset(Control.PRESET_CENTER)
	dialogue.choice_made.connect(_on_choice)
	ui_layer.add_child(dialogue)

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

	toast = Label.new()
	toast.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	toast.offset_left = -420
	toast.offset_top = -36
	toast.text = "[WASD] move   [E] interact   [L] event log   [F3] debug"
	ui_layer.add_child(toast)

	gs.event_log.event_appended.connect(func(_event: Dictionary) -> void:
		party_panel.refresh(gs))
	_rebuild_world()
	party_panel.refresh(gs)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_log"):
		log_panel.toggle()
	elif event.is_action_pressed("toggle_debug"):
		debug_overlay.toggle()


## --- Overworld interactions -------------------------------------------------

func _on_interacted(kind: String, target_id: String) -> void:
	if dialogue.visible or combat_screen != null:
		return
	match kind:
		"exit":
			var result := gs.move_to_area(target_id)
			if bool(result["ok"]):
				_rebuild_world()
			else:
				_show_toast(String(result["error"]))
		"npc":
			dialogue.open(DialogueData.for_npc(target_id, gs))
		"shrine":
			dialogue.open(DialogueData.shrine(gs))
		"ruin":
			dialogue.open(DialogueData.ruin(gs))
		"fight":
			if gs.can_fight(target_id):
				_start_combat(target_id)


## --- Dialogue actions ---------------------------------------------------------

func _on_choice(action: String, args: Dictionary) -> void:
	match action:
		"close":
			dialogue.close()
		"learn_and_start_quest":
			dialogue.close()
			gs.learn_technique("player", "technique_a")
			gs.set_flag("quest_a_started", true)
			gs.event_log.append("quest_started",
					"<elder A> asked the party to deal with the band holding <ruin C>.",
					{"quest_id": "quest_a"})
			_show_toast("Learned <technique A; strike>. Quest started: the band at <ruin C>.")
		"accept_pact":
			dialogue.close()
			gs.contract_spirit("spirit_a", 2)
			_rebuild_world()
			_show_toast("<spirit A> joins the party. The vow of blood cost 2 max HP.")
		"fight_encounter":
			dialogue.close()
			_start_combat(String(args["encounter_id"]))
		"negotiate_ruin":
			dialogue.close()
			gs.set_flag("quest_a_resolved_talk", true)
			gs.set_flag("quest_a_done", true)
			gs.event_log.append("quest_resolved",
					"<spirit A> carried the party's words on the wind. The band abandoned "
					+ "<ruin C> without a fight.",
					{"quest_id": "quest_a", "resolution": "negotiated"})
			_rebuild_world()
			_show_toast("The band leaves the ruin. Word of this will spread.")
		"restart":
			get_tree().reload_current_scene()
		_:
			push_warning("Unknown dialogue action: %s" % action)
			dialogue.close()


## --- Combat -------------------------------------------------------------------

func _start_combat(encounter_id: String) -> void:
	_active_encounter_id = encounter_id
	var encounter := db.encounter(encounter_id)
	var combat := CombatState.new(db, gs.rng, gs.event_log, encounter, gs.party)
	world.process_mode = Node.PROCESS_MODE_DISABLED
	world.hide()
	combat_screen = CombatScreen.new()
	ui_layer.add_child(combat_screen)
	combat_screen.finished.connect(_on_combat_finished)
	combat_screen.start(combat, encounter.intro_text)


func _on_combat_finished(outcome: int) -> void:
	combat_screen.queue_free()
	combat_screen = null
	world.process_mode = Node.PROCESS_MODE_INHERIT
	world.show()
	if outcome == CombatState.Outcome.VICTORY:
		gs.apply_combat_outcome(_active_encounter_id, true)
		if _active_encounter_id == "enc_ruin":
			gs.set_flag("quest_a_done", true)
	elif outcome == CombatState.Outcome.DEFEAT:
		gs.apply_combat_outcome(_active_encounter_id, false)
		dialogue.open({
			"title": "The party has fallen",
			"lines": ["The run ends here. The world will not remember this one."],
			"choices": [{"label": "Start a new run", "action": "restart", "args": {}}],
		})
	_active_encounter_id = ""
	_rebuild_world()
	party_panel.refresh(gs)


## --- Helpers ------------------------------------------------------------------

func _rebuild_world() -> void:
	world.build(db.area(gs.current_area_id), db, gs)


func _show_toast(text: String) -> void:
	toast.text = text
	var timer := get_tree().create_timer(4.0)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(toast):
			toast.text = "[WASD] move   [E] interact   [L] event log   [F3] debug")
