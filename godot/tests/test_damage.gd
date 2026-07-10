extends RefCounted
## Unit tests for damage/status/break math.


func _dummy_enemy(hp: int, toughness: int, weak: PackedStringArray) -> Combatant:
	var def := EnemyDef.new()
	def.id = "dummy"
	def.display_name = "<dummy>"
	def.max_hp = hp
	def.toughness = toughness
	def.weak_tags = weak
	return Combatant.from_enemy(def, 0)


func run(t: TestHarness) -> void:
	t.context("damage")
	var target := _dummy_enemy(20, 4, PackedStringArray(["force"]))

	t.eq(Damage.compute_hit(4, 0, target), 4, "plain hit deals base power")

	target.add_status("vulnerable", 2)
	t.eq(Damage.compute_hit(4, 0, target), 6, "vulnerable adds +50%")

	target.add_status("guard", 1)
	t.eq(Damage.compute_hit(4, 0, target), 3, "guard halves after vulnerable")
	var dealt := Damage.apply_hit(4, 0, target)
	t.eq(dealt, 3, "apply_hit returns damage dealt")
	t.eq(target.status("guard"), 0, "guard stack consumed by the hit")
	t.eq(target.hp(), 17, "hp reduced by dealt amount")

	t.context("break")
	t.ok(not Damage.apply_break("ember", 2, target), "wrong element does not break")
	t.eq(target.toughness, 4, "toughness untouched by wrong element")
	t.ok(not Damage.apply_break("force", 2, target), "partial depletion does not break")
	t.eq(target.toughness, 2, "matching element depletes toughness")
	t.ok(Damage.apply_break("force", 2, target), "reaching zero breaks the target")
	t.ok(target.broken, "target is broken")
	target.statuses.clear()
	t.eq(Damage.compute_hit(4, 0, target), 6, "broken targets take +50%")
	t.ok(not Damage.apply_break("force", 2, target), "already-broken cannot re-break")

	t.context("damage floor")
	var tough := _dummy_enemy(10, 0, PackedStringArray())
	tough.add_status("guard", 5)
	t.eq(Damage.compute_hit(1, 0, tough), 1, "damage never drops below 1")
