extends SceneTree
## Headless sim-test runner (no addon needed).
##
## Run from the repo root:
##   godot/tests/run_headless.sh
## Exits 0 when green, 1 when any assertion failed.

const TEST_SCRIPTS: Array[String] = [
	"res://tests/test_paper_doll.gd",
	"res://tests/test_technique.gd",
	"res://tests/test_damage.gd",
	"res://tests/test_game_state.gd",
	"res://tests/test_economy.gd",
	"res://tests/test_combat.gd",
]


func _initialize() -> void:
	var harness := TestHarness.new()
	for path in TEST_SCRIPTS:
		var script := load(path) as GDScript
		if script == null:
			harness.ok(false, "could not load %s" % path)
			continue
		var test: Object = script.new()
		if not test.has_method("run"):
			harness.ok(false, "%s has no run method" % path)
			continue
		print("running %s" % path)
		test.run(harness)
	print("")
	if harness.passed():
		print("PASS — %d checks" % harness.checks)
	else:
		print("FAIL — %d of %d checks failed:" % [harness.failures.size(), harness.checks])
		for failure in harness.failures:
			print("  ✗ %s" % failure)
	quit(0 if harness.passed() else 1)
