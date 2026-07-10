class_name TechniqueState
extends RefCounted
## Runtime state of one learned technique on one actor: use-driven proficiency.

var def: TechniqueDef
var uses: int = 0


func _init(p_def: TechniqueDef) -> void:
	def = p_def


func level() -> int:
	return TechniqueDef.level_for_uses(uses)


func level_name() -> String:
	return TechniqueDef.LEVEL_NAMES[level()]


func power() -> int:
	return def.power_for_level(level())


func qi_cost() -> int:
	return def.cost_for_level(level())


## Records one use. Returns the new level if a threshold was crossed, else -1.
func record_use() -> int:
	var before := level()
	uses += 1
	var after := level()
	return after if after > before else -1
