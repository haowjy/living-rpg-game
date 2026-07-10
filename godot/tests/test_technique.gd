extends RefCounted
## Unit tests for technique proficiency math.


func run(t: TestHarness) -> void:
	t.context("technique")
	var def := TechniqueDef.new()
	def.id = "test_tech"
	def.display_name = "<test tech>"
	def.base_power = 3
	def.base_qi_cost = 3

	t.eq(TechniqueDef.level_for_uses(0), 0, "0 uses is untrained")
	t.eq(TechniqueDef.level_for_uses(3), 1, "3 uses is novice")
	t.eq(TechniqueDef.level_for_uses(8), 2, "8 uses is competent")
	t.eq(TechniqueDef.level_for_uses(36), 4, "36 uses is master")

	var state := TechniqueState.new(def)
	t.eq(state.power(), 3, "untrained power is base power")
	t.eq(state.qi_cost(), 3, "untrained cost is base cost")

	var leveled := -1
	for i in 3:
		leveled = state.record_use()
	t.eq(leveled, 1, "third use crosses the novice threshold")
	t.eq(state.level_name(), "novice", "level name after 3 uses")
	t.eq(state.power(), 4, "novice adds +1 power")

	for i in 5:
		state.record_use()
	t.eq(state.level(), 2, "8 uses reaches competent")
	t.eq(state.qi_cost(), 2, "competent discounts qi cost by 1")
