class_name CombatState
extends RefCounted
## Deterministic turn-based battle sim. "Commands in, events out":
## the UI asks for the current combatant and legal commands, submits one
## command Dictionary, and renders the event Dictionaries that come back.
## Every event is also appended to the run's EventLog.

enum Outcome { NONE, VICTORY, DEFEAT, FLED }

var db: ContentDB
var rng: RngService
var event_log: EventLog
var encounter: EncounterDef

var party: Array[Combatant] = []
var enemies: Array[Combatant] = []
var queue: Array[Combatant] = []
var turn_index: int = 0
var round_number: int = 1
var outcome: Outcome = Outcome.NONE
## Combatant ids whose holder-only first-strike passive has fired this combat.
var first_strike_landed: Dictionary = {}
## True after begin_turn() when the current combatant's turn was consumed
## automatically (broken stun, burn death) — the driver should not act.
var turn_consumed: bool = false


func _init(p_db: ContentDB, p_rng: RngService, p_log: EventLog,
		p_encounter: EncounterDef, p_party: Array[ActorState]) -> void:
	db = p_db
	rng = p_rng
	event_log = p_log
	encounter = p_encounter
	first_strike_landed.clear()
	for actor in p_party:
		if actor.is_alive():
			party.append(Combatant.from_actor(actor))
	var index := 0
	for enemy_id in p_encounter.enemy_ids:
		enemies.append(Combatant.from_enemy(db.enemy(enemy_id), index))
		index += 1
	_build_queue()
	event_log.append("combat_started", "Battle joined: %s." % encounter.display_name,
			{"encounter_id": encounter.id, "round": round_number})


## --- Turn flow --------------------------------------------------------------

func current() -> Combatant:
	return queue[turn_index]


func is_over() -> bool:
	return outcome != Outcome.NONE


## Runs automatic start-of-turn effects for the current combatant.
## Returns events. If the turn was consumed (stun/death), also advances.
func begin_turn() -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	turn_consumed = false
	var c := current()
	if not c.is_alive():
		turn_consumed = true
		_advance()
		return events
	var burn := c.status("burn")
	if burn > 0:
		var dealt := burn
		c.set_hp(c.hp() - dealt)
		c.decrement_status("burn")
		events.append(_log("burn_tick", "%s takes %d burn damage." % [c.display_name, dealt],
				{"target_id": c.id, "amount": dealt}))
		if not c.is_alive():
			events.append(_log("actor_downed", "%s falls." % c.display_name, {"actor_id": c.id}))
			events.append_array(_check_end())
			turn_consumed = true
			if not is_over():
				_advance()
			return events
	if c.broken:
		c.broken = false
		c.toughness = c.max_toughness
		events.append(_log("break_recovered",
				"%s is staggered and loses its turn." % c.display_name, {"actor_id": c.id}))
		turn_consumed = true
		_end_of_turn(c)
		_advance()
	return events


## Legal commands for the current (party) combatant, for the UI.
func available_commands() -> Array[Dictionary]:
	var c := current()
	var commands: Array[Dictionary] = [{"kind": "attack", "label": "Attack"}]
	if c.actor != null:
		for t in c.actor.techniques:
			commands.append({
				"kind": "technique",
				"technique_id": t.def.id,
				"label": "%s (%d qi)" % [t.def.display_name, t.qi_cost()],
				"affordable": c.qi() >= t.qi_cost(),
			})
		if c.is_spirit() and c.actor.spirit.is_bonded():
			commands.append({"kind": "invoke", "label": c.actor.spirit.def.invoke_name})
	commands.append({"kind": "guard", "label": "Guard"})
	commands.append({"kind": "flee", "label": "Flee"})
	return commands


## Executes a party command. Returns events; invalid commands return a
## single command_rejected event and do not consume the turn.
func perform(command: Dictionary) -> Array[Dictionary]:
	var c := current()
	if c.is_enemy:
		return [_log("command_rejected", "It is not the party's turn.", {})]
	var events: Array[Dictionary] = []
	match String(command.get("kind", "")):
		"attack":
			var target := _target_from(command)
			if target == null:
				return [_reject("Invalid target.")]
			events.append_array(_strike(c, target, c.attack + _passive_bonus(c), "", 0, "attacks"))
		"technique":
			var t := c.actor.technique_by_id(String(command.get("technique_id", "")))
			if t == null:
				return [_reject("Unknown technique.")]
			var target := c if t.def.target_self else _target_from(command)
			if target == null:
				return [_reject("Invalid target.")]
			if c.qi() < t.qi_cost():
				return [_reject("Not enough qi for %s." % t.def.display_name)]
			c.spend_qi(t.qi_cost())
			events.append_array(_use_technique(c, target, t))
		"invoke":
			if not c.is_spirit() or not c.actor.spirit.is_bonded():
				return [_reject("Invoke is not available.")]
			events.append_array(_invoke(c))
		"guard":
			var guard_stacks := 2
			var bonded_spirit := _bonded_spirit_for(c)
			if bonded_spirit != null and bonded_spirit.passive_kind == "guard_on_guard":
				guard_stacks += bonded_spirit.passive_amount
			c.add_status("guard", guard_stacks)
			events.append(_log("status_applied", "%s guards." % c.display_name,
					{"target_id": c.id, "status": "guard", "stacks": guard_stacks}))
		"flee":
			outcome = Outcome.FLED
			events.append(_log("fled", "The party fled the battle.", {}))
			return events
		_:
			return [_reject("Unknown command.")]
	events.append_array(_check_end())
	if not is_over():
		_end_of_turn(c)
		_advance()
	return events


## Executes the current enemy's turn.
func enemy_act() -> Array[Dictionary]:
	var c := current()
	if not c.is_enemy:
		return [_log("command_rejected", "It is the party's turn.", {})]
	var events: Array[Dictionary] = []
	var move := _pick_move(c)
	var target := _lowest_hp(party)
	if target != null:
		events.append_array(_strike(c, target, c.attack + int(move.get("power", 0)),
				String(move.get("applies_status", "")), int(move.get("status_stacks", 0)),
				String(move.get("name", "attacks"))))
	events.append_array(_check_end())
	if not is_over():
		_end_of_turn(c)
		_advance()
	return events


## --- Actions ----------------------------------------------------------------

func _strike(attacker: Combatant, target: Combatant, power: int,
		applies_status: String, status_stacks: int, verb: String) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	var dealt := Damage.apply_hit(power, 0, target)
	events.append(_log("damage_dealt",
			"%s %s %s for %d." % [attacker.display_name, verb, target.display_name, dealt],
			{"attacker_id": attacker.id, "target_id": target.id, "amount": dealt}))
	var bonded_spirit := _bonded_spirit_for(attacker)
	if bonded_spirit != null and bonded_spirit.passive_kind == "first_hit_burn" \
			and not first_strike_landed.has(attacker.id):
		first_strike_landed[attacker.id] = true
		if target.is_alive():
			target.add_status("burn", bonded_spirit.passive_amount)
			events.append(_log("status_applied",
					"%s gains %d burn." % [target.display_name, bonded_spirit.passive_amount],
					{"target_id": target.id, "status": "burn",
						"stacks": bonded_spirit.passive_amount}))
	if applies_status != "" and status_stacks > 0 and target.is_alive():
		target.add_status(applies_status, status_stacks)
		events.append(_log("status_applied",
				"%s gains %d %s." % [target.display_name, status_stacks, applies_status],
				{"target_id": target.id, "status": applies_status, "stacks": status_stacks}))
	if not target.is_alive():
		events.append(_log("actor_downed", "%s falls." % target.display_name,
				{"actor_id": target.id}))
	return events


func _use_technique(c: Combatant, target: Combatant, t: TechniqueState) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	var broke := false
	var dealt := 0
	if not t.def.target_self:
		var power := t.power() + c.attack + _passive_bonus(c)
		broke = Damage.apply_break(t.def.element, t.def.break_power, target)
		dealt = Damage.apply_hit(power, 0, target)
	events.append(_log("technique_used",
			"%s uses %s on %s for %d." % [c.display_name, t.def.display_name,
				target.display_name, dealt],
			{"attacker_id": c.id, "target_id": target.id,
				"technique_id": t.def.id, "amount": dealt}))
	if broke:
		events.append(_log("break_triggered",
				"%s is broken by %s!" % [target.display_name, t.def.element],
				{"target_id": target.id, "element": t.def.element}))
	if t.def.applies_status != "" and target.is_alive():
		target.add_status(t.def.applies_status, t.def.status_stacks)
		events.append(_log("status_applied",
				"%s gains %d %s." % [target.display_name, t.def.status_stacks,
					t.def.applies_status],
				{"target_id": target.id, "status": t.def.applies_status,
					"stacks": t.def.status_stacks}))
	if not target.is_alive():
		events.append(_log("actor_downed", "%s falls." % target.display_name,
				{"actor_id": target.id}))
	var new_level := t.record_use()
	if new_level >= 0:
		events.append(_log("proficiency_gained",
				"%s's %s reaches %s." % [c.display_name, t.def.display_name,
					TechniqueDef.LEVEL_NAMES[new_level]],
				{"actor_id": c.id, "technique_id": t.def.id, "level": new_level}))
	return events


func _invoke(c: Combatant) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	var def := c.actor.spirit.def
	events.append(_log("spirit_invoked", "%s invokes %s!" % [c.display_name, def.invoke_name],
			{"spirit_id": def.id}))
	if def.invoke_kind == "party_guard_cleanse":
		for member in party:
			member.add_status("guard", 1)
			member.decrement_status("burn", member.status("burn"))
			events.append(_log("status_applied", "%s gains 1 guard." % member.display_name,
					{"target_id": member.id, "status": "guard", "stacks": 1}))
	else:
		var targets: Array[Combatant] = []
		if def.invoke_hits_all:
			targets = _living(enemies)
		else:
			var single := _lowest_hp(enemies)
			if single != null:
				targets = [single]
		for target in targets:
			var broke := Damage.apply_break(def.element, 2, target)
			var dealt := Damage.apply_hit(def.invoke_power, 0, target)
			events.append(_log("damage_dealt",
					"%s hits %s for %d." % [def.invoke_name, target.display_name, dealt],
					{"attacker_id": c.id, "target_id": target.id, "amount": dealt}))
			if broke:
				events.append(_log("break_triggered",
						"%s is broken by %s!" % [target.display_name, def.element],
						{"target_id": target.id, "element": def.element}))
			if def.invoke_status != "" and target.is_alive():
				target.add_status(def.invoke_status, def.invoke_status_stacks)
				events.append(_log("status_applied",
						"%s gains %d %s." % [target.display_name,
							def.invoke_status_stacks, def.invoke_status],
						{"target_id": target.id, "status": def.invoke_status,
							"stacks": def.invoke_status_stacks}))
			if not target.is_alive():
				events.append(_log("actor_downed", "%s falls." % target.display_name,
						{"actor_id": target.id}))
	c.actor.spirit.begin_rest()
	events.append(_log("spirit_resting",
			"%s slips into rest (%d rounds)." % [c.display_name, def.rest_rounds],
			{"spirit_id": def.id, "rounds": def.rest_rounds}))
	return events


## --- Internals --------------------------------------------------------------

func _build_queue() -> void:
	queue.clear()
	for c in _living(party) + _living(enemies):
		queue.append(c)
	queue.sort_custom(func(a: Combatant, b: Combatant) -> bool:
		if a.speed != b.speed:
			return a.speed > b.speed
		if a.is_enemy != b.is_enemy:
			return not a.is_enemy
		return a.id < b.id)
	turn_index = 0


func _advance() -> void:
	turn_index += 1
	while turn_index < queue.size() and not queue[turn_index].is_alive():
		turn_index += 1
	if turn_index >= queue.size():
		_end_round()


func _end_round() -> void:
	round_number += 1
	for c in party:
		if c.is_spirit() and c.actor.spirit.tick_rest():
			_log("spirit_rebonded", "%s returns to the bond." % c.display_name,
					{"spirit_id": c.actor.spirit.def.id})
	_build_queue()


func _end_of_turn(c: Combatant) -> void:
	if c.status("vulnerable") > 0:
		c.decrement_status("vulnerable")


func _check_end() -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	if _living(enemies).is_empty():
		outcome = Outcome.VICTORY
		events.append(_log("combat_victory", "The party is victorious.", {}))
	elif _living(party).is_empty():
		outcome = Outcome.DEFEAT
		events.append(_log("combat_defeat", "The party has fallen.", {}))
	return events


func _pick_move(enemy: Combatant) -> Dictionary:
	var moves := enemy.enemy_def.moves
	if moves.is_empty():
		return {"name": "attacks", "power": 0}
	var total := 0
	for move in moves:
		total += maxi(1, int(move.get("weight", 1)))
	var pick := rng.roll(1, total)
	for move in moves:
		pick -= maxi(1, int(move.get("weight", 1)))
		if pick <= 0:
			return move
	return moves[0]


func _passive_bonus(c: Combatant) -> int:
	var def := _bonded_spirit_for(c)
	if def != null and def.passive_kind == "stat_buff" and def.passive_stat == "attack":
		return def.passive_amount
	return 0


func _bonded_spirit_for(c: Combatant) -> SpiritDef:
	# The current single-spirit contract belongs to the player.
	if c.is_enemy or c.actor == null or c.actor.id != "player":
		return null
	for member in party:
		if member.is_spirit() and member.is_alive() and member.actor.spirit.is_bonded():
			return member.actor.spirit.def
	return null


func _living(group: Array[Combatant]) -> Array[Combatant]:
	var alive: Array[Combatant] = []
	for c in group:
		if c.is_alive():
			alive.append(c)
	return alive


func _lowest_hp(group: Array[Combatant]) -> Combatant:
	var best: Combatant = null
	for c in _living(group):
		if best == null or c.hp() < best.hp():
			best = c
	return best


func _target_from(command: Dictionary) -> Combatant:
	var target_id := String(command.get("target_id", ""))
	for c in _living(enemies):
		if c.id == target_id:
			return c
	return null


func _reject(message: String) -> Dictionary:
	return _log("command_rejected", message, {})


func _log(type: String, summary: String, data: Dictionary) -> Dictionary:
	data["round"] = round_number
	return event_log.append(type, summary, data)
