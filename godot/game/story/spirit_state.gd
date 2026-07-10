class_name SpiritState
extends RefCounted
## Runtime contract state of a bonded spirit.
##
## BONDED: passive active on the contract holder, Invoke available.
## RESTING: after an Invoke — passive suspended, Invoke unavailable,
## recovers after def.rest_rounds combat rounds (or any area transition).

enum ContractState { BONDED, RESTING }

var def: SpiritDef
var contract_state: ContractState = ContractState.BONDED
var rest_remaining: int = 0


func _init(p_def: SpiritDef) -> void:
	def = p_def


func is_bonded() -> bool:
	return contract_state == ContractState.BONDED


func begin_rest() -> void:
	contract_state = ContractState.RESTING
	rest_remaining = def.rest_rounds


## Ticks one combat round of rest. Returns true if the spirit re-bonded.
func tick_rest() -> bool:
	if contract_state != ContractState.RESTING:
		return false
	rest_remaining -= 1
	if rest_remaining <= 0:
		contract_state = ContractState.BONDED
		rest_remaining = 0
		return true
	return false


## Out-of-combat recovery (travel rests the spirit fully).
func recover() -> void:
	contract_state = ContractState.BONDED
	rest_remaining = 0
