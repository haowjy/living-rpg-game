class_name EnemyDef
extends Resource
## Authored definition of an enemy combatant.

@export var id: String = ""
@export var display_name: String = ""

@export_group("Stats")
@export var max_hp: int = 12
@export var speed: int = 4
@export var attack: int = 3

@export_group("Break meter")
## Toughness points; reaches 0 -> broken (stunned one round, takes bonus damage).
@export var toughness: int = 0
## Element tags this enemy is weak to; only matching hits deplete toughness.
@export var weak_tags: PackedStringArray = PackedStringArray()

## Moves: array of {"name": String, "power": int, "applies_status": String,
## "status_stacks": int, "weight": int}. Chosen by seeded RNG weight.
@export var moves: Array[Dictionary] = []
