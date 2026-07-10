extends SceneTree
## Headless sim-test runner (no addon needed).
##
## Run from the repo root:
##   godot --headless --path godot -s res://tests/run_tests.gd
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
		var script: GDScript = load(path)
		if script == null:
			harness.failures.append("could not load %s" % path)
			continue
		var test: RefCounted = script.new()
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
