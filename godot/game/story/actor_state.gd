class_name ActorState
extends RefCounted
## Persistent runtime state of a party member (human or spirit) across
## the whole run. Combat reads from and writes back to this.

var id: String
var display_name: String
var max_hp: int
var hp: int
var max_qi: int
var qi: int
var speed: int
var attack: int
## Learned techniques in learn order.
var techniques: Array[TechniqueState] = []
## Non-null only for the spirit party member.
var spirit: SpiritState = null


func _init(p_id: String, p_name: String, p_max_hp: int, p_max_qi: int,
		p_speed: int, p_attack: int) -> void:
	id = p_id
	display_name = p_name
	max_hp = p_max_hp
	hp = p_max_hp
	max_qi = p_max_qi
	qi = p_max_qi
	speed = p_speed
	attack = p_attack


static func from_spirit_def(def: SpiritDef) -> ActorState:
	var actor := ActorState.new(
		def.id, def.display_name, def.max_hp, def.max_qi, def.speed, def.attack)
	actor.spirit = SpiritState.new(def)
	return actor


func is_spirit() -> bool:
	return spirit != null


func is_alive() -> bool:
	return hp > 0


func technique_by_id(technique_id: String) -> TechniqueState:
	for t in techniques:
		if t.def.id == technique_id:
			return t
	return null


## Rest between areas: restore qi, revive to at least 1 hp, rest spirit.
func travel_recover() -> void:
	qi = max_qi
	hp = maxi(hp, 1)
	if spirit != null:
		spirit.recover()
