extends RefCounted
## Headless presentation checks for paper-doll direction and frame synchronization.

const PAPER_DOLL_SCENE := preload("res://game/actors/paper_doll_character.tscn")


func run(t: TestHarness) -> void:
	t.context("paper doll")
	var visual := PAPER_DOLL_SCENE.instantiate() as PaperDollCharacter
	var layers := _sprite_layers(visual)

	t.eq(layers.size(), 3, "scene stacks a body and two overlay layers")
	for layer in layers:
		t.eq(layer.texture.get_size(), Vector2(256, 256),
				"%s uses a 4x4 sheet of 64px cells" % layer.name)
		t.eq(layer.hframes, 4, "%s has four walk frames" % layer.name)
		t.eq(layer.vframes, 4, "%s has four direction rows" % layer.name)

	visual.set_motion(Vector2.UP)
	_assert_synchronized(t, layers, Vector2i(0, 3), "faces up")
	visual._process(0.125)
	_assert_synchronized(t, layers, Vector2i(1, 3), "advances the up walk cycle")

	visual.set_motion(Vector2.RIGHT)
	_assert_synchronized(t, layers, Vector2i(1, 2), "changes direction without resetting gait")
	visual._process(0.125)
	_assert_synchronized(t, layers, Vector2i(2, 2), "advances the right walk cycle")

	visual.set_motion(Vector2.LEFT)
	_assert_synchronized(t, layers, Vector2i(2, 1), "faces left")
	visual.set_motion(Vector2.DOWN)
	_assert_synchronized(t, layers, Vector2i(2, 0), "faces down")

	visual.set_motion(Vector2.ZERO)
	_assert_synchronized(t, layers, Vector2i(0, 0), "returns to the current direction's idle frame")
	visual.free()


func _sprite_layers(visual: PaperDollCharacter) -> Array[Sprite2D]:
	var layers: Array[Sprite2D] = []
	for child in visual.get_children():
		if child is Sprite2D:
			layers.append(child as Sprite2D)
	return layers


func _assert_synchronized(t: TestHarness, layers: Array[Sprite2D],
		expected: Vector2i, message: String) -> void:
	for layer in layers:
		t.eq(layer.frame_coords, expected, "%s: %s" % [message, layer.name])
