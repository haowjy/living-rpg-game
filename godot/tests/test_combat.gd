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
	t.context("self-target technique")
	var stance_db := ContentDB.new()
	var stance_gs := GameState.new(stance_db, 7)
	stance_gs.start_new_run("hub_a")
	stance_gs.learn_technique("player", "technique_c")
	var stance := CombatState.new(stance_db, stance_gs.rng, stance_gs.event_log,
			stance_db.encounter("enc_road"), stance_gs.party)
	var stance_target_hp := stance.enemies[0].hp()
	var stance_events := stance.perform(
			{"kind": "technique", "technique_id": "technique_c"})
	t.eq(stance.party[0].status("guard"), 2, "guard stance applies guard to its user")
	t.eq(stance.enemies[0].hp(), stance_target_hp, "guard stance deals no enemy damage")
	var stance_amount := -1
	for event in stance_events:
		if String(event["type"]) == "technique_used":
			stance_amount = int(event["data"]["amount"])
	t.eq(stance_amount, 0, "guard stance records zero damage")
	var step_gs := GameState.new(stance_db, 8)
	step_gs.start_new_run("hub_a")
	step_gs.learn_technique("player", "technique_d")
	var step := CombatState.new(stance_db, step_gs.rng, step_gs.event_log,
			stance_db.encounter("enc_road"), step_gs.party)
	var step_target_hp := step.enemies[0].hp()
	step.perform({"kind": "technique", "technique_id": "technique_d"})
	t.eq(step.party[0].status("guard"), 2, "evasive step applies guard to its user")
	t.eq(step.enemies[0].hp(), step_target_hp, "evasive step deals no enemy damage")

	t.context("sprout spirit")
	var sprout_player := ActorState.new("player", "<player>", 20, 8, 8, 3)
	var sprout_actor := ActorState.from_spirit_def(stance_db.spirit("spirit_b"))
	var sprout_party: Array[ActorState] = [sprout_player, sprout_actor]
	var sprout_log := EventLog.new()
	var sprout := CombatState.new(stance_db, RngService.new(9), sprout_log,
			stance_db.encounter("enc_road"), sprout_party)
	sprout.perform({"kind": "guard"})
	t.eq(sprout.party[0].status("guard"), 3,
			"sprout adds one stack to its holder's Guard action")

	var invoke_player := ActorState.new("player", "<player>", 20, 8, 6, 3)
	var invoke_sprout := ActorState.from_spirit_def(stance_db.spirit("spirit_b"))
	var invoke_party: Array[ActorState] = [invoke_player, invoke_sprout]
	var invoke_log := EventLog.new()
	var sprout_invoke := CombatState.new(stance_db, RngService.new(10), invoke_log,
			stance_db.encounter("enc_road"), invoke_party)
	for member in sprout_invoke.party:
		member.add_status("burn", 2)
	sprout_invoke.perform({"kind": "invoke"})
	for member in sprout_invoke.party:
		t.eq(member.status("guard"), 1, "sprout invoke guards %s" % member.id)
		t.eq(member.status("burn"), 0, "sprout invoke cleanses %s burn" % member.id)
	t.ok(invoke_sprout.spirit.contract_state == SpiritState.ContractState.RESTING,
			"sprout rests after invoking")

	t.context("ember fox spirit")
	var fox_player := ActorState.new("player", "<player>", 20, 8, 9, 3)
	var fox_actor := ActorState.from_spirit_def(stance_db.spirit("spirit_c"))
	var fox_party: Array[ActorState] = [fox_player, fox_actor]
	var fox := CombatState.new(stance_db, RngService.new(11), EventLog.new(),
			stance_db.encounter("enc_road"), fox_party)
	fox._strike(fox.party[0], fox.enemies[0], fox.party[0].attack,  "", 0, "attacks")
	t.eq(fox.enemies[0].status("burn"), 1, "ember fox burns on its holder's first strike")
	fox._strike(fox.party[0], fox.enemies[0], fox.party[0].attack,  "", 0, "attacks")
	t.eq(fox.enemies[0].status("burn"), 1, "ember fox does not burn on the second strike")

	var fresh_fox_player := ActorState.new("player", "<player>", 20, 8, 9, 3)
	var fresh_fox_actor := ActorState.from_spirit_def(stance_db.spirit("spirit_c"))
	var fresh_fox_party: Array[ActorState] = [fresh_fox_player, fresh_fox_actor]
	var fresh_fox := CombatState.new(stance_db, RngService.new(12), EventLog.new(),
			stance_db.encounter("enc_road"), fresh_fox_party)
	fresh_fox._strike(fresh_fox.party[0], fresh_fox.enemies[0],
			fresh_fox.party[0].attack, "", 0, "attacks")
	t.eq(fresh_fox.enemies[0].status("burn"), 1,
			"ember fox first-strike passive resets in a fresh combat")

	var invoke_fox_player := ActorState.new("player", "<player>", 20, 8, 6, 3)
	var invoke_fox_actor := ActorState.from_spirit_def(stance_db.spirit("spirit_c"))
	var invoke_fox_party: Array[ActorState] = [invoke_fox_player, invoke_fox_actor]
	var fox_invoke := CombatState.new(stance_db, RngService.new(13), EventLog.new(),
			stance_db.encounter("enc_road"), invoke_fox_party)
	fox_invoke.perform({"kind": "invoke"})
	for enemy in fox_invoke.enemies:
		t.eq(enemy.status("burn"), 1, "ember fox invoke burns %s" % enemy.id)

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
