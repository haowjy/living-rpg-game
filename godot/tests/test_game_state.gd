extends RefCounted
## Tests for overworld commands and the Arc A state transitions.

func run(t: TestHarness) -> void:
	var db := ContentDB.new()
	var gs := GameState.new(db, 42)
	gs.start_new_run("hub_a")

	t.context("semi-progressed start")
	t.eq(gs.party.size(), 2, "run starts with player and companion")
	t.eq(gs.current_area_id, "hub_a", "run starts in hub")
	t.ok(gs.gold > 0, "run starts with gold")
	var starting_form := gs.player().technique_by_id("technique_a")
	t.ok(starting_form != null, "player starts knowing technique_a")
	t.eq(starting_form.uses, 8, "starting technique_a has competent uses")
	t.eq(starting_form.level_name(), "competent", "starting technique_a is competent")
	t.ok(gs.party[1].technique_by_id("technique_b") != null, "companion keeps technique_b")
	t.eq(gs.event_log.entries.size(), 1, "run start is logged")

	t.context("movement")
	var bad := gs.move_to_area("ruin_c")
	t.ok(not bad["ok"], "moving to a non-adjacent area is rejected")
	t.eq(gs.current_area_id, "hub_a", "rejected move does not change area")
	var good := gs.move_to_area("road_b")
	t.ok(good["ok"], "moving along an exit succeeds")
	t.eq(gs.current_area_id, "road_b", "area updates on move")

	t.context("techniques")
	var again := gs.learn_technique("player", "technique_a")
	t.ok(not again["ok"], "cannot learn a starting technique twice")
	var guard := gs.learn_technique("player", "technique_c")
	t.ok(guard["ok"], "elder reward technique can be learned")

	t.context("spirit contract")
	var without_item := GameState.new(db, 42)
	without_item.start_new_run("shrine_d")
	var rejected_contract := without_item.contract_spirit("spirit_a")
	t.ok(not rejected_contract["ok"], "spirit contract requires its item")
	t.eq(rejected_contract["error"], "You need a spirit contract.", "missing item error is explicit")
	var hp_before := without_item.player().max_hp
	without_item.inventory["item_spirit_contract"] = 1
	var contracted := without_item.contract_spirit("spirit_b")
	t.ok(contracted["ok"], "chosen spirit can be contracted")
	t.eq(without_item.inventory["item_spirit_contract"], 0, "spirit contract item is consumed")
	t.eq(without_item.player().max_hp, hp_before, "spirit contract deducts no max HP")
	t.eq(without_item.player().hp, hp_before, "spirit contract deducts no current HP")
	t.eq(without_item.party.size(), 3, "chosen spirit joins the party")
	t.eq(without_item.party[2].id, "spirit_b", "the selected spirit is bonded")
	var contract_event := without_item.event_log.entries[-1]
	t.eq(contract_event["data"], {"spirit_id": "spirit_b", "holder_id": "player"}, "contract event identifies spirit and holder")
	without_item.inventory["item_spirit_contract"] = 1
	var second := without_item.contract_spirit("spirit_c")
	t.ok(not second["ok"], "only one spirit may be bonded")
	t.eq(without_item.inventory["item_spirit_contract"], 1, "second-spirit rejection does not consume an item")

	t.context("reinstate resolution")
	var reinstated := GameState.new(db, 42)
	reinstated.start_new_run("ruin_c")
	reinstated.set_flag("quest_a_started", true)
	reinstated.inventory["item_spirit_contract"] = 1
	reinstated.contract_spirit("spirit_c")
	var reinstate_result := reinstated.reinstate_road_watch()
	t.ok(reinstate_result["ok"], "a spirit can witness reinstating the watch")
	t.ok(reinstated.flag("quest_a_resolved_talk"), "reinstate sets talk resolution")
	t.ok(reinstated.flag("quest_a_done"), "reinstate completes the quest")
	t.ok(reinstated.flag("road_watch_reinstated"), "reinstate records the road watch")
	t.ok(not reinstated.can_fight("enc_road"), "reinstated watch removes the road encounter")

	t.context("expose resolution")
	var exposed := GameState.new(db, 42)
	exposed.start_new_run("ruin_c")
	exposed.set_flag("quest_a_started", true)
	t.ok(exposed.take_charter()["ok"], "party can take the unpaid charter")
	t.ok(exposed.flag("has_charter"), "taking charter records possession")
	var gold_before := exposed.gold
	t.ok(exposed.expose_charter()["ok"], "charter can be exposed to the reeve")
	t.ok(exposed.flag("quest_a_resolved_expose"), "expose sets its resolution flag")
	t.ok(exposed.flag("marshal_heard"), "expose reaches the marshal")
	t.ok(exposed.flag("quest_a_done"), "expose completes the quest")
	t.ok(exposed.gold > gold_before, "exposing the charter pays gold")

	t.context("mentor lesson")
	var student := GameState.new(db, 42)
	student.start_new_run("road_b")
	t.ok(student.receive_mentor_lesson()["ok"], "mentor teaches technique_d")
	t.ok(student.flag("mentor_taught"), "mentor lesson is flagged")
	t.ok(student.player().technique_by_id("technique_d") != null, "mentor lesson adds technique_d")
	t.ok(not student.receive_mentor_lesson()["ok"], "mentor teaches only once")

	t.context("marshal closing hook")
	var combat := GameState.new(db, 42)
	combat.start_new_run("ruin_c")
	combat.apply_combat_outcome("enc_ruin", true)
	for resolved in [combat, reinstated, exposed]:
		t.ok(resolved.flag("quest_a_done"), "each resolution completes the quest")
		t.ok(resolved.see_marshal_offer()["ok"], "marshal offers work after any resolution")
		t.ok(resolved.flag("marshal_offer_seen"), "marshal offer is recorded after any resolution")

	t.context("encounter gating")
	t.ok(combat.flag("quest_a_resolved_combat"), "ruin victory sets combat resolution")
	t.ok(not combat.can_fight("enc_ruin"), "non-repeatable fight closes after victory")
	var open_road := GameState.new(db, 42)
	open_road.start_new_run("road_b")
	t.ok(open_road.can_fight("enc_road"), "road fight repeats before reinstatement")

	t.context("event log")
	var seqs: Array = exposed.event_log.entries.map(func(e: Dictionary) -> int: return e["seq"])
	for i in seqs.size():
		t.eq(seqs[i], i, "event seq is dense and ordered")
	var jsonl := exposed.event_log.to_jsonl()
	t.eq(jsonl.split("\n").size(), exposed.event_log.entries.size(), "jsonl has one line per event")
