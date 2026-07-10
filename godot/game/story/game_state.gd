class_name GameState
extends RefCounted
## The deterministic overworld sim: party, flags, location, and the rules
## for every out-of-combat state change. Owns the run's single EventLog
## and seeded RNG. UI dispatches commands here; nothing else mutates state.

var db: ContentDB
var rng: RngService
var event_log: EventLog

var current_area_id: String = ""
var day: int = 1
## Four daily segments: Morning, Midday, Evening, Night.
var time_of_day: int = 0
var gold: int = 0
## Item id -> count.
var inventory: Dictionary = {}
## World flags: String -> bool/int. The only quest/world memory.
var flags: Dictionary = {}
var party: Array[ActorState] = []


func _init(p_db: ContentDB, p_seed: int) -> void:
	db = p_db
	rng = RngService.new(p_seed)
	event_log = EventLog.new()


## --- Boot -----------------------------------------------------------------

func start_new_run(start_area_id: String) -> void:
	var player := ActorState.new("player", "<player>", 20, 8, 6, 3)
	var companion := ActorState.new("companion_a", "<companion A>", 16, 6, 5, 2)
	party = [player, companion]
	current_area_id = start_area_id
	event_log.append("run_started", "A new run begins in %s." % _area_name(start_area_id),
			{"seed": rng.seed_value, "area_id": start_area_id})


func player() -> ActorState:
	return party[0]


## --- Commands ---------------------------------------------------------------
## Commands validate first and return {"ok": bool, "error": String}.

func move_to_area(area_id: String) -> Dictionary:
	var here := db.area(current_area_id)
	if not here.exits.has(area_id):
		return _fail("No path from %s to %s." % [here.id, area_id])
	var destination := db.area(area_id)
	current_area_id = area_id
	for actor in party:
		actor.travel_recover()
	event_log.append("traveled", "The party traveled to %s." % _area_name(area_id),
			{"from": here.id, "to": area_id})
	if here.advances_time and destination.advances_time:
		advance_time()
	return _ok()


func advance_time(segments: int = 1) -> Dictionary:
	if segments < 1:
		return _fail("Time must advance by at least one segment.")
	var elapsed := time_of_day + segments
	day += elapsed >> 2
	time_of_day = elapsed % 4
	event_log.append("time_advanced", "It is now Day %d — %s." % [day, time_of_day_name()],
			{"day": day, "time_of_day": time_of_day})
	return _ok()


func time_of_day_name() -> String:
	return ["Morning", "Midday", "Evening", "Night"][time_of_day]


func rest() -> Dictionary:
	if current_area_id != "hub_a":
		return _fail("The party can only rest at <hub A>.")
	for actor in party:
		actor.hp = actor.max_hp
		actor.qi = actor.max_qi
	advance_time(4 - time_of_day)
	event_log.append("rested", "The party rested until Morning.",
			{"day": day, "time_of_day": time_of_day})
	return _ok()


func buy(item_id: String) -> Dictionary:
	var item_def := db.item(item_id)
	if not _merchant_sells_here(item_id):
		return _fail("No merchant here sells %s." % item_def.display_name)
	if gold < item_def.price:
		return _fail("Not enough gold to buy %s." % item_def.display_name)
	gold -= item_def.price
	inventory[item_id] = int(inventory.get(item_id, 0)) + 1
	event_log.append("item_bought", "Bought %s." % item_def.display_name,
			{"item_id": item_id, "price": item_def.price, "gold": gold})
	return _ok()


func sell(item_id: String) -> Dictionary:
	if int(inventory.get(item_id, 0)) < 1:
		return _fail("The party does not own that item.")
	var item_def := db.item(item_id)
	var refund := item_def.price >> 1
	_consume_item(item_id)
	gold += refund
	event_log.append("item_sold", "Sold %s." % item_def.display_name,
			{"item_id": item_id, "refund": refund, "gold": gold})
	return _ok()


func use_item(item_id: String) -> Dictionary:
	if int(inventory.get(item_id, 0)) < 1:
		return _fail("The party does not own that item.")
	var item_def := db.item(item_id)
	if item_def.kind == "spirit_contract":
		return _fail("Nothing happens here.")
	if item_def.kind != "consumable":
		return _fail("That item cannot be used.")
	var restored := mini(item_def.heal_hp, player().max_hp - player().hp)
	player().hp += restored
	_consume_item(item_id)
	event_log.append("item_used", "Used %s." % item_def.display_name,
			{"item_id": item_id, "actor_id": player().id, "heal_hp": restored})
	return _ok()


func _consume_item(item_id: String) -> bool:
	var count := int(inventory.get(item_id, 0))
	if count < 1:
		return false
	inventory[item_id] = count - 1
	return true


func learn_technique(actor_id: String, technique_id: String) -> Dictionary:
	var actor := _actor(actor_id)
	if actor == null:
		return _fail("Unknown actor: %s" % actor_id)
	if actor.technique_by_id(technique_id) != null:
		return _fail("%s already knows %s." % [actor.display_name, technique_id])
	var def := db.technique(technique_id)
	actor.techniques.append(TechniqueState.new(def))
	event_log.append("technique_learned",
			"%s learned %s." % [actor.display_name, def.display_name],
			{"actor_id": actor_id, "technique_id": technique_id})
	return _ok()


## Contract a spirit at a shrine. The pact has a visible cost: a vow of
## blood — the contract holder permanently gives up vow_hp_cost max HP.
func contract_spirit(spirit_id: String, vow_hp_cost: int = 2) -> Dictionary:
	for actor in party:
		if actor.is_spirit():
			return _fail("A spirit is already bonded to this party.")
	var def := db.spirit(spirit_id)
	var holder := player()
	holder.max_hp -= vow_hp_cost
	holder.hp = mini(holder.hp, holder.max_hp)
	var spirit_actor := ActorState.from_spirit_def(def)
	party.append(spirit_actor)
	set_flag("spirit_contracted", true)
	event_log.append("spirit_contracted",
			"%s sealed a pact with %s. The vow of blood costs %d max HP."
				% [holder.display_name, def.display_name, vow_hp_cost],
			{"spirit_id": spirit_id, "holder_id": holder.id, "vow_hp_cost": vow_hp_cost})
	return _ok()


func set_flag(flag: String, value: Variant) -> void:
	flags[flag] = value
	event_log.append("flag_set", "World state changed: %s = %s." % [flag, value],
			{"flag": flag, "value": value})


func flag(name: String, default: Variant = false) -> Variant:
	return flags.get(name, default)


## Whether an encounter can currently be fought.
func can_fight(encounter_id: String) -> bool:
	var enc := db.encounter(encounter_id)
	if enc.repeatable:
		return true
	return not flag(enc.victory_flag, false)


## Called by the combat layer when a battle ends.
func apply_combat_outcome(encounter_id: String, victory: bool) -> void:
	var enc := db.encounter(encounter_id)
	if victory and enc.victory_flag != "":
		set_flag(enc.victory_flag, true)
	event_log.append("combat_ended",
			"%s: %s." % [enc.display_name, "victory" if victory else "defeat"],
			{"encounter_id": encounter_id, "victory": victory})


## --- Helpers ----------------------------------------------------------------

func _actor(actor_id: String) -> ActorState:
	for actor in party:
		if actor.id == actor_id:
			return actor
	return null


func _area_name(area_id: String) -> String:
	return db.area(area_id).display_name


func _merchant_sells_here(item_id: String) -> bool:
	for npc_id in db.area(current_area_id).npc_ids:
		var npc_def := db.npc(npc_id)
		if npc_def.role == "merchant" and npc_def.goods.has(item_id):
			return true
	return false


func _ok() -> Dictionary:
	return {"ok": true, "error": ""}


func _fail(message: String) -> Dictionary:
	push_warning("Command rejected: %s" % message)
	event_log.append("command_rejected", message, {})
	return {"ok": false, "error": message}
