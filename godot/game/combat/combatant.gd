class_name Combatant
extends RefCounted
## One participant in a battle. Wraps either a persistent party ActorState
## (changes write back to it) or an EnemyDef instance (combat-local).

var id: String
var display_name: String
var is_enemy: bool
var max_hp: int
var speed: int
var attack: int
## Status name -> stacks. See Damage for semantics.
var statuses: Dictionary = {}

## Break meter (enemies only; 0 max_toughness = unbreakable).
var max_toughness: int = 0
var toughness: int = 0
var weak_tags: PackedStringArray = PackedStringArray()
var broken: bool = false

## Party-side link, null for enemies.
var actor: ActorState = null
## Enemy-side link, null for party.
var enemy_def: EnemyDef = null
## Enemy hp is combat-local; party hp lives on the ActorState.
var _enemy_hp: int = 0


static func from_actor(p_actor: ActorState) -> Combatant:
	var c := Combatant.new()
	c.actor = p_actor
	c.id = p_actor.id
	c.display_name = p_actor.display_name
	c.is_enemy = false
	c.max_hp = p_actor.max_hp
	c.speed = p_actor.speed
	c.attack = p_actor.attack
	return c


static func from_enemy(def: EnemyDef, instance_index: int) -> Combatant:
	var c := Combatant.new()
	c.enemy_def = def
	c.id = "%s#%d" % [def.id, instance_index]
	c.display_name = def.display_name
	c.is_enemy = true
	c.max_hp = def.max_hp
	c._enemy_hp = def.max_hp
	c.speed = def.speed
	c.attack = def.attack
	c.max_toughness = def.toughness
	c.toughness = def.toughness
	c.weak_tags = def.weak_tags
	return c


func hp() -> int:
	return actor.hp if actor != null else _enemy_hp


func set_hp(value: int) -> void:
	var clamped := clampi(value, 0, max_hp)
	if actor != null:
		actor.hp = clamped
	else:
		_enemy_hp = clamped


func qi() -> int:
	return actor.qi if actor != null else 0


func spend_qi(amount: int) -> void:
	if actor != null:
		actor.qi = maxi(0, actor.qi - amount)


func is_alive() -> bool:
	return hp() > 0


func is_spirit() -> bool:
	return actor != null and actor.is_spirit()


func status(name: String) -> int:
	return statuses.get(name, 0)


func add_status(name: String, stacks: int) -> void:
	statuses[name] = status(name) + stacks


func decrement_status(name: String, by: int = 1) -> void:
	var remaining := status(name) - by
	if remaining <= 0:
		statuses.erase(name)
	else:
		statuses[name] = remaining
