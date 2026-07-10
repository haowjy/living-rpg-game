class_name EncounterDef
extends Resource
## Authored definition of a combat encounter.

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var intro_text: String = ""
## EnemyDef ids fielded in this encounter, in rank order.
@export var enemy_ids: PackedStringArray = PackedStringArray()
## Flag set to true in GameState when this encounter is won.
@export var victory_flag: String = ""
## If true the encounter can be replayed after victory.
@export var repeatable: bool = false
