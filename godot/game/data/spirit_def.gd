class_name SpiritDef
extends Resource
## Authored definition of a contractable spirit.
##
## A spirit fights as a party member and has three contract states:
## BONDED (passive buff active on its contract holder, Invoke available),
## INVOKED is momentary (the big move fires), then RESTING (passive
## suspended, Invoke unavailable) for rest_rounds rounds.

@export var id: String = ""
@export var display_name: String = ""
@export var element: String = ""

@export_group("Combatant stats")
@export var max_hp: int = 10
@export var max_qi: int = 6
@export var speed: int = 5
@export var attack: int = 2

@export_group("Bonded passive (applies to contract holder)")
## Selects the spirit's small bonded-passive hook.
@export_enum("stat_buff", "guard_on_guard", "first_hit_burn")
var passive_kind: String = "stat_buff"
## Stat modified by the stat-buff passive.
@export_enum("attack") var passive_stat: String = "attack"
@export var passive_amount: int = 1

@export_group("Invoke move")
## Selects the spirit's invoke behavior.
@export_enum("enemy_hit", "party_guard_cleanse") var invoke_kind: String = "enemy_hit"
@export var invoke_name: String = ""
@export var invoke_power: int = 6
## Status applied to all enemies on Invoke, "" for none.
@export var invoke_status: String = ""
@export var invoke_status_stacks: int = 0
## True: Invoke hits all enemies. False: single target.
@export var invoke_hits_all: bool = true
## Rounds the spirit spends RESTING after an Invoke.
@export var rest_rounds: int = 2
