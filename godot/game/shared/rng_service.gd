class_name RngService
extends RefCounted
## Deterministic RNG for the sim core.
##
## All sim randomness must flow through one injected instance so a run can be
## reproduced from its seed. Presentation code must never use this.

var seed_value: int
var _rng := RandomNumberGenerator.new()

func _init(p_seed: int = 1) -> void:
	seed_value = p_seed
	_rng.seed = p_seed


## Inclusive integer roll.
func roll(min_value: int, max_value: int) -> int:
	return _rng.randi_range(min_value, max_value)


## Returns true with the given percent chance (0-100).
func chance(percent: int) -> bool:
	return roll(1, 100) <= percent


## Deterministic pick from a non-empty array.
func pick(options: Array) -> Variant:
	assert(not options.is_empty())
	return options[roll(0, options.size() - 1)]
