extends RefCounted
## Tests for overworld commands: movement validation, pacts, flags, log.


func run(t: TestHarness) -> void:
	t.context("game_state")
	var db := ContentDB.new()
	var gs := GameState.new(db, 42)
	gs.start_new_run("hub_a")

	t.eq(gs.party.size(), 2, "run starts with player and companion")
	t.eq(gs.current_area_id, "hub_a", "run starts in hub")
	t.eq(gs.event_log.entries.size(), 1, "run start is logged")

	var bad := gs.move_to_area("ruin_c")
	t.ok(not bad["ok"], "moving to a non-adjacent area is rejected")
	t.eq(gs.current_area_id, "hub_a", "rejected move does not change area")

	var good := gs.move_to_area("road_b")
	t.ok(good["ok"], "moving along an exit succeeds")
	t.eq(gs.current_area_id, "road_b", "area updates on move")

	t.context("techniques")
	var learn := gs.learn_technique("player", "technique_a")
	t.ok(learn["ok"], "player can learn technique_a")
	var again := gs.learn_technique("player", "technique_a")
	t.ok(not again["ok"], "cannot learn the same technique twice")

	t.context("spirit pact")
	var hp_before := gs.player().max_hp
	var pact := gs.contract_spirit("spirit_a", 2)
	t.ok(pact["ok"], "pact succeeds at the shrine")
	t.eq(gs.player().max_hp, hp_before - 2, "vow of blood costs max hp")
	t.eq(gs.party.size(), 3, "spirit joins the party")
	t.ok(gs.party[2].is_spirit(), "third member is the spirit")
	var second := gs.contract_spirit("spirit_a", 2)
	t.ok(not second["ok"], "only one spirit may be bonded")

	t.context("encounter gating")
	t.ok(gs.can_fight("enc_ruin"), "quest fight available before victory")
	gs.apply_combat_outcome("enc_ruin", true)
	t.ok(gs.flag("quest_a_resolved_combat"), "victory sets the encounter flag")
	t.ok(not gs.can_fight("enc_ruin"), "non-repeatable fight closes after victory")
	t.ok(gs.can_fight("enc_road"), "repeatable fight stays open")

	t.context("event log")
	t.ok(gs.event_log.entries.size() >= 6, "commands write events")
	var seqs: Array = gs.event_log.entries.map(func(e: Dictionary) -> int: return e["seq"])
	for i in seqs.size():
		t.eq(seqs[i], i, "event seq is dense and ordered")
	var jsonl := gs.event_log.to_jsonl()
	t.eq(jsonl.split("\n").size(), gs.event_log.entries.size(), "jsonl has one line per event")
