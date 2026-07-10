class_name TechniqueDef
extends Resource
## Authored definition of a learnable technique (martial form).

## Proficiency ladder: uses required to reach each level.
## Index = level: 0 untrained, 1 novice, 2 competent, 3 expert, 4 master.
const LEVEL_NAMES: Array[String] = ["untrained", "novice", "competent", "expert", "master"]
const LEVEL_THRESHOLDS: Array[int] = [0, 3, 8, 18, 36]
## Flat power bonus per proficiency level.
const LEVEL_POWER_BONUS: Array[int] = [0, 1, 3, 5, 8]
## Qi discount per proficiency level (clamped so cost never drops below 1).
const LEVEL_QI_DISCOUNT: Array[int] = [0, 0, 1, 1, 2]

## Stable content id, e.g. "technique_a".
@export var id: String = ""
## Placeholder display name, e.g. "<technique A; strike>".
@export var display_name: String = ""
## Element/type tag used for break-meter matching, e.g. "force", "ember".
@export var element: String = ""
## Base damage before stat and proficiency bonuses.
@export var base_power: int = 0
## Qi cost at Untrained proficiency. Mastery reduces it (see cost_for_level).
@export var base_qi_cost: int = 0
## Status applied to the target on hit, "" for none (e.g. "vulnerable").
@export var applies_status: String = ""
## Stacks of applies_status added on hit.
@export var status_stacks: int = 0
## Damage the technique deals to an enemy's toughness (break) meter
## when the element matches one of the enemy's weak tags.
@export var break_power: int = 1


static func level_for_uses(uses: int) -> int:
	var level := 0
	for i in LEVEL_THRESHOLDS.size():
		if uses >= LEVEL_THRESHOLDS[i]:
			level = i
	return level


func power_for_level(level: int) -> int:
	return base_power + LEVEL_POWER_BONUS[clampi(level, 0, 4)]


func cost_for_level(level: int) -> int:
	return maxi(1, base_qi_cost - LEVEL_QI_DISCOUNT[clampi(level, 0, 4)])
