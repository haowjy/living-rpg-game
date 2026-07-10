class_name TestHarness
extends RefCounted
## Minimal assertion collector for headless sim tests. No addon needed:
## run via `godot --headless --path godot -s res://tests/run_tests.gd`.

var checks: int = 0
var failures: PackedStringArray = PackedStringArray()
var _context: String = ""


func context(name: String) -> void:
	_context = name


func ok(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append("[%s] %s" % [_context, message])


func eq(actual: Variant, expected: Variant, message: String) -> void:
	checks += 1
	if actual != expected:
		failures.append("[%s] %s — expected %s, got %s"
				% [_context, message, expected, actual])


func passed() -> bool:
	return failures.is_empty()
