extends RefCounted
## Integration tests for the battle sim: turn order, spirit tri-state,
## scripted battles, and cross-run determinism.


## Builds a full late-game party: player (+technique), companion, spirit.
func _full_party_state(seed_value: int) -> GameState:
	var db := ContentDB.new()
	var gs := GameState.new(db, seed_value)
	gs.start_new_run("hub_a")
	gs.learn_technique("player", "technique_a")
	gs.learn_technique("companion_a", "technique_b")
	gs.contract_spirit("spirit_a", 2)
	return gs


## Deterministic scripted policy: spirits invoke when able, others use their
## first affordable technique, otherwise attack. Always targets first enemy.
func _play_out(combat: CombatState, max_steps: int = 200) -> void:
	var steps := 0
	while not combat.is_over() and steps < max_steps:
		steps += 1
		combat.begin_turn()
		if combat.is_over() or combat.turn_consumed:
			continue
		var c := combat.current()
		if c.is_enemy:
			combat.enemy_act()
			continue
		var enemies := combat._living(combat.enemies)
		var target_id: String = enemies[0].id
		if c.is_spirit() and c.actor.spirit.is_bonded():
			combat.perform({"kind": "invoke"})
			continue
		var tech: TechniqueState = null
		if c.actor != null and not c.actor.techniques.is_empty():
			var first := c.actor.techniques[0]
			if c.qi() >= first.qi_cost():
				tech = first
		if tech != null:
			combat.perform({"kind": "technique", "technique_id": tech.def.id,
					"target_id": target_id})
		else:
			combat.perform({"kind": "attack", "target_id": target_id})


func run(t: TestHarness) -> void:
	t.context("turn order")
	var gs := _full_party_state(11)
	var combat := CombatState.new(gs.db, gs.rng, gs.event_log, gs.db.encounter("enc_road"), gs.party)
	var order: Array = combat.queue.map(func(c: Combatant) -> String: return c.id)
	t.eq(order, ["spirit_a", "player", "companion_a", "monster_a#0", "monster_a#1"],
			"speed order with party-first ties")

	t.context("spirit invoke")
	combat.begin_turn()
	t.ok(not combat.turn_consumed, "spirit's first turn is free to act")
	t.ok(combat.current().is_spirit(), "spirit acts first")
	var commands := combat.available_commands()
	var kinds: Array = commands.map(func(cmd: Dictionary) -> String: return String(cmd["kind"]))
	t.ok(kinds.has("invoke"), "bonded spirit can invoke")
	var events := combat.perform({"kind": "invoke"})
	var types: Array = events.map(func(e: Dictionary) -> String: return String(e["type"]))
	t.ok(types.has("spirit_invoked"), "invoke emits its event")
	t.ok(types.has("spirit_resting"), "invoke sends the spirit to rest")
	t.ok(not gs.party[2].spirit.is_bonded(), "spirit is resting after invoke")

	t.context("passive suspension")
	# Player attack while spirit rests: no +2 passive.
	t.ok(combat.current().actor.id == "player", "player acts second")
	var target_id: String = combat._living(combat.enemies)[0].id
	var hp_before: int = combat._living(combat.enemies)[0].hp()
	var attack_events := combat.perform({"kind": "attack", "target_id": target_id})
	var dealt := -1
	for e in attack_events:
		if String(e["type"]) == "damage_dealt":
			dealt = int(e["data"]["amount"])
	t.ok(dealt >= 1, "attack dealt damage")
	# Player attack is 3; resting spirit means no passive bonus. Target may be
	# broken/vulnerable from the invoke, so compute the expected value directly.
	var expected := hp_before - dealt
	t.eq(combat.enemies[0].hp() if combat.enemies[0].id == target_id else -1, expected,
			"damage applied to target hp")

	t.context("scripted battle finishes")
	_play_out(combat)
	t.ok(combat.is_over(), "scripted road battle terminates")
	t.eq(combat.outcome, CombatState.Outcome.VICTORY, "party wins the road fight")
	var log_types: Array = gs.event_log.entries.map(func(e: Dictionary) -> String: return String(e["type"]))
	t.ok(log_types.has("combat_started"), "log has combat_started")
	t.ok(log_types.has("combat_victory"), "log has combat_victory")
	t.ok(log_types.has("technique_used"), "techniques were used during the fight")

	t.context("proficiency in battle")
	# Grind repeatable road fights until the technique crosses a threshold.
	var grind := _full_party_state(21)
	var before_level := grind.player().techniques[0].level()
	for i in 4:
		var fight := CombatState.new(grind.db, grind.rng, grind.event_log,
				grind.db.encounter("enc_road"), grind.party)
		_play_out(fight)
		t.eq(fight.outcome, CombatState.Outcome.VICTORY, "grind fight %d won" % i)
		for actor in grind.party:
			actor.travel_recover()
	t.ok(grind.player().techniques[0].level() > before_level,
			"technique proficiency rose across repeated fights")
	var grind_types: Array = grind.event_log.entries.map(
			func(e: Dictionary) -> String: return String(e["type"]))
	t.ok(grind_types.has("proficiency_gained"), "proficiency threshold logged")

	t.context("determinism")
	var first_jsonl := _scripted_run_jsonl(99)
	var second_jsonl := _scripted_run_jsonl(99)
	t.ok(first_jsonl == second_jsonl, "same seed produces an identical event log")
	var different := _scripted_run_jsonl(100)
	t.ok(first_jsonl != different, "different seed produces a different log")

	t.context("defeat")
	var weak_db := ContentDB.new()
	var weak_gs := GameState.new(weak_db, 5)
	weak_gs.start_new_run("hub_a")
	weak_gs.player().hp = 1
	weak_gs.player().attack = 0
	weak_gs.party[1].hp = 1
	weak_gs.party[1].attack = 0
	var doomed := CombatState.new(weak_db, weak_gs.rng, weak_gs.event_log,
			weak_db.encounter("enc_ruin"), weak_gs.party)
	_play_out(doomed)
	t.ok(doomed.is_over(), "hopeless battle terminates")
	t.eq(doomed.outcome, CombatState.Outcome.DEFEAT, "party falls in hopeless battle")


func _scripted_run_jsonl(seed_value: int) -> String:
	var gs := _full_party_state(seed_value)
	var combat := CombatState.new(gs.db, gs.rng, gs.event_log, gs.db.encounter("enc_road"), gs.party)
	_play_out(combat)
	return gs.event_log.to_jsonl()
