extends SceneTree
## Deterministic, self-authored placeholder art generator.
## Run: godot --headless --path godot -s res://tools/gen_assets.gd

# VISUAL CONTRACT — the complete Living RPG placeholder palette.
# Every visible pixel produced below is sampled from these slightly desaturated,
# warm DS-era colors. Transparent pixels are the sole non-palette value.
# Greens: ground texture and layered foliage.
const GRASS_DARK := Color("405c45")
const GRASS_MID := Color("5f7c50")
const GRASS_LIGHT := Color("91a765")
const FOLIAGE_DARK := Color("2f4d3b")
const FOLIAGE_MID := Color("52704a")
# Earth: paths, soil, and wetlands.
const PATH_LIGHT := Color("d1b77b")
const PATH_MID := Color("aa8d62")
const DIRT := Color("866448")
const MUD := Color("594c43")
# Stone: architecture and ruins.
const STONE_DARK := Color("4f5660")
const STONE_MID := Color("7b7c79")
const STONE_LIGHT := Color("ada594")
const RUBBLE := Color("756b62")
# Water.
const WATER_DARK := Color("315b6b")
const WATER_MID := Color("477d88")
const WATER_LIGHT := Color("8fb6ad")
# Wood.
const WOOD_DARK := Color("594236")
const WOOD_MID := Color("93694b")
# World accents.
const FLOWER_RED := Color("b95756")
const FLOWER_YELLOW := Color("d6b85e")
const SHRINE_TEAL := Color("4d8980")
# Character bases.
const SKIN := Color("d7a77f")
const CLOTH_A := Color("536f91")
const CLOTH_B := Color("9a5b55")
const CLOTH_C := Color("77714e")
const CLOTH_D := Color("695c83")
const CLOTH_E := Color("47766c")
const HAIR_DARK := Color("3b3334")
# Interface.
const INK := Color("292d35")
const PARCHMENT := Color("e2cf9c")
const BAR_RED := Color("ae4c4b")
const BAR_BLUE := Color("42758e")
const GOLD := Color("c5984c")

const CLEAR := Color(0, 0, 0, 0)
const OUTPUT_DIR := "res://game/assets/generated"
const TILE_SIZE := 32
const TILE_COLUMNS := 8
const FIXED_SEED := 0x5EED2026
const TILE_NAMES: Array[String] = [
	"grass", "grass_flowers", "path", "path_edge_n",
	"path_edge_e", "path_edge_s", "path_edge_w", "dirt",
	"water", "water_shore", "tree", "tree_top",
	"bush", "rock", "boulder", "stone_wall",
	"wall_top", "rubble", "floor_wood", "floor_stone",
	"door", "fence", "bridge_plank", "shrine_stone",
	"water_lily", "mud", "path_corner", "grass_tuft",
	"stump", "stone_steps", "flower_patch", "signpost",
]

var _written: Array[Dictionary] = []


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR + "/ui"))
	_generate_tiles()
	_generate_characters()
	_generate_enemies()
	_generate_ui()
	_write_manifest()
	print("\nTILE GRID INDEX (8 columns, 32 px cells)")
	for index in TILE_NAMES.size():
		print("%02d -> %-16s -> (%d,%d)" % [index, TILE_NAMES[index], index % TILE_COLUMNS, index / TILE_COLUMNS])
	print("\nGENERATED PNG REPORT")
	var failed := false
	for entry in _written:
		var loaded: Image = Image.load_from_file(ProjectSettings.globalize_path(entry.path))
		var ok: bool = loaded != null and loaded.get_width() == entry.width and loaded.get_height() == entry.height
		failed = failed or not ok
		print("%s — %dx%d — %s" % [entry.path.trim_prefix("res://"), entry.width, entry.height, "OK" if ok else "FAILED"])
	print("Manifest: game/assets/ASSET-MANIFEST.md")
	quit(1 if failed else 0)


func _new_image(width: int, height: int, fill: Color = CLEAR) -> Image:
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(fill)
	return image


func _save(image: Image, relative_path: String) -> void:
	var path := OUTPUT_DIR + "/" + relative_path
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save %s (error %d)" % [path, error])
	_written.append({"path": path, "width": image.get_width(), "height": image.get_height()})


func _pixel(image: Image, x: int, y: int, color: Color) -> void:
	if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
		image.set_pixelv(Vector2i(x, y), color)


func _rect(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	for py in range(y, y + height):
		for px in range(x, x + width):
			_pixel(image, px, py, color)


func _hline(image: Image, x: int, y: int, width: int, color: Color) -> void:
	_rect(image, x, y, width, 1, color)


func _vline(image: Image, x: int, y: int, height: int, color: Color) -> void:
	_rect(image, x, y, 1, height, color)


func _hash(x: int, y: int, salt: int = 0) -> int:
	var value := (x * 374761393 + y * 668265263 + salt * 69069 + FIXED_SEED) & 0x7fffffff
	value = ((value ^ (value >> 13)) * 1274126177) & 0x7fffffff
	return value ^ (value >> 16)


func _tile_origin(index: int) -> Vector2i:
	return Vector2i(index % TILE_COLUMNS, index / TILE_COLUMNS) * TILE_SIZE


func _tile_base(atlas: Image, index: int, base: Color, light: Color, dark: Color, density: int = 13) -> Vector2i:
	var origin := _tile_origin(index)
	_rect(atlas, origin.x, origin.y, TILE_SIZE, TILE_SIZE, base)
	for y in TILE_SIZE:
		for x in TILE_SIZE:
			var roll := _hash(x, y, index) % 100
			if roll < density:
				_pixel(atlas, origin.x + x, origin.y + y, light if roll % 3 else dark)
	# Ground-tile edge shading is restrained so adjacent cells still tile cleanly.
	_hline(atlas, origin.x, origin.y + 31, 32, dark)
	return origin


func _generate_tiles() -> void:
	var atlas := _new_image(TILE_COLUMNS * TILE_SIZE, 4 * TILE_SIZE)
	var o: Vector2i
	# Grass variants.
	o = _tile_base(atlas, 0, GRASS_MID, GRASS_LIGHT, GRASS_DARK, 10)
	for p in [Vector2i(4, 8), Vector2i(14, 21), Vector2i(25, 12)]:
		_pixel(atlas, o.x + p.x, o.y + p.y, GRASS_LIGHT)
		_pixel(atlas, o.x + p.x + 1, o.y + p.y - 2, GRASS_DARK)
	o = _tile_base(atlas, 1, GRASS_MID, GRASS_LIGHT, GRASS_DARK, 9)
	for p in [Vector2i(7, 9), Vector2i(23, 7), Vector2i(17, 24), Vector2i(28, 19)]:
		_pixel(atlas, o.x + p.x, o.y + p.y, FLOWER_YELLOW if p.x % 2 else FLOWER_RED)
		_pixel(atlas, o.x + p.x + 1, o.y + p.y, GRASS_LIGHT)
	# Packed earth and transitions.
	_tile_base(atlas, 2, PATH_MID, PATH_LIGHT, DIRT, 18)
	for index in range(3, 7):
		o = _tile_base(atlas, index, GRASS_MID, GRASS_LIGHT, GRASS_DARK, 8)
		var side := index - 3
		for y in 32:
			for x in 32:
				var path_pixel := (side == 0 and y < 12) or (side == 1 and x >= 20) or (side == 2 and y >= 20) or (side == 3 and x < 12)
				if path_pixel:
					_pixel(atlas, o.x + x, o.y + y, PATH_LIGHT if _hash(x, y, index) % 9 == 0 else PATH_MID)
	_tile_base(atlas, 7, DIRT, PATH_MID, MUD, 16)
	# Water and shore.
	for index in [8, 9]:
		o = _tile_base(atlas, index, WATER_MID, WATER_LIGHT, WATER_DARK, 5)
		for ripple in [Vector3i(3, 7, 10), Vector3i(17, 15, 11), Vector3i(6, 24, 14)]:
			_hline(atlas, o.x + ripple.x, o.y + ripple.y, ripple.z, WATER_LIGHT)
			_hline(atlas, o.x + ripple.x + 3, o.y + ripple.y + 1, ripple.z - 5, WATER_DARK)
	if true:
		o = _tile_origin(9)
		for x in 32:
			var shore_y := 22 + (_hash(x, 9) % 3)
			for y in range(shore_y, 32):
				_pixel(atlas, o.x + x, o.y + y, PATH_LIGHT if y == shore_y else PATH_MID)
	# Tree body and canopy extension.
	for index in [10, 11]:
		o = _tile_base(atlas, index, GRASS_MID, GRASS_LIGHT, GRASS_DARK, 6)
		_rect(atlas, o.x + 14, o.y + 18, 5, 13, INK)
		_rect(atlas, o.x + 15, o.y + 18, 3, 12, WOOD_DARK)
		_rect(atlas, o.x + 4, o.y + 8, 24, 15, INK)
		_rect(atlas, o.x + 6, o.y + 5, 20, 16, FOLIAGE_DARK)
		_rect(atlas, o.x + 9, o.y + 3, 14, 16, FOLIAGE_MID)
		_rect(atlas, o.x + 11, o.y + 5, 7, 4, GRASS_LIGHT)
	if true:
		o = _tile_origin(11)
		_rect(atlas, o.x + 5, o.y + 18, 22, 12, FOLIAGE_DARK)
		_rect(atlas, o.x + 8, o.y + 14, 16, 12, FOLIAGE_MID)
	# Bush.
	o = _tile_base(atlas, 12, GRASS_MID, GRASS_LIGHT, GRASS_DARK, 7)
	_rect(atlas, o.x + 5, o.y + 13, 22, 14, INK)
	_rect(atlas, o.x + 7, o.y + 10, 18, 15, FOLIAGE_DARK)
	_rect(atlas, o.x + 10, o.y + 9, 7, 8, FOLIAGE_MID)
	_rect(atlas, o.x + 12, o.y + 10, 3, 3, GRASS_LIGHT)
	# Rocks.
	for index in [13, 14]:
		o = _tile_base(atlas, index, GRASS_MID, GRASS_LIGHT, GRASS_DARK, 6)
		var inset := 7 if index == 13 else 4
		_rect(atlas, o.x + inset, o.y + 11, 32 - inset * 2, 15, INK)
		_rect(atlas, o.x + inset + 2, o.y + 9, 28 - inset * 2, 14, STONE_DARK)
		_rect(atlas, o.x + inset + 4, o.y + 10, 20 - inset, 7, STONE_MID)
		_hline(atlas, o.x + inset + 5, o.y + 11, 8, STONE_LIGHT)
	# Walls and cap.
	for index in [15, 16]:
		o = _tile_base(atlas, index, STONE_MID, STONE_LIGHT, STONE_DARK, 8)
		_rect(atlas, o.x, o.y, 32, 2, INK)
		for y in [10, 20, 30]:
			_hline(atlas, o.x, o.y + y, 32, STONE_DARK)
		for x in [8, 24]:
			_vline(atlas, o.x + x, o.y, 10, STONE_DARK)
			_vline(atlas, o.x + (32 - x), o.y + 10, 10, STONE_DARK)
	if true:
		o = _tile_origin(16)
		_rect(atlas, o.x, o.y, 32, 5, INK)
		_rect(atlas, o.x + 2, o.y + 2, 28, 5, STONE_LIGHT)
	# Ruin rubble.
	o = _tile_base(atlas, 17, DIRT, PATH_MID, MUD, 10)
	for rock in [Vector4i(3, 18, 8, 5), Vector4i(14, 8, 10, 7), Vector4i(23, 22, 6, 5)]:
		_rect(atlas, o.x + rock.x, o.y + rock.y, rock.z, rock.w, INK)
		_rect(atlas, o.x + rock.x + 1, o.y + rock.y, rock.z - 2, rock.w - 1, RUBBLE)
	# Floors.
	o = _tile_base(atlas, 18, WOOD_MID, PATH_LIGHT, WOOD_DARK, 6)
	for y in [0, 8, 16, 24, 31]:
		_hline(atlas, o.x, o.y + y, 32, WOOD_DARK)
	for p in [Vector2i(5, 4), Vector2i(22, 12), Vector2i(10, 28)]:
		_hline(atlas, o.x + p.x, o.y + p.y, 6, PATH_MID)
	o = _tile_base(atlas, 19, STONE_MID, STONE_LIGHT, STONE_DARK, 5)
	for y in [0, 10, 21, 31]:
		_hline(atlas, o.x, o.y + y, 32, STONE_DARK)
	for x in [9, 23]:
		_vline(atlas, o.x + x, o.y, 10, STONE_DARK)
		_vline(atlas, o.x + (32 - x), o.y + 10, 11, STONE_DARK)
	# Door.
	o = _tile_base(atlas, 20, STONE_MID, STONE_LIGHT, STONE_DARK, 4)
	_rect(atlas, o.x + 5, o.y + 2, 22, 30, INK)
	_rect(atlas, o.x + 8, o.y + 5, 16, 27, WOOD_DARK)
	_rect(atlas, o.x + 10, o.y + 7, 12, 24, WOOD_MID)
	_rect(atlas, o.x + 19, o.y + 19, 2, 2, GOLD)
	# Fence and bridge.
	o = _tile_base(atlas, 21, GRASS_MID, GRASS_LIGHT, GRASS_DARK, 7)
	_rect(atlas, o.x, o.y + 13, 32, 9, INK)
	_rect(atlas, o.x, o.y + 15, 32, 5, WOOD_MID)
	for x in [4, 25]:
		_rect(atlas, o.x + x, o.y + 8, 4, 19, WOOD_DARK)
	o = _tile_base(atlas, 22, WOOD_MID, PATH_LIGHT, WOOD_DARK, 4)
	_rect(atlas, o.x, o.y, 2, 32, INK)
	_rect(atlas, o.x + 30, o.y, 2, 32, INK)
	for y in range(0, 32, 6):
		_hline(atlas, o.x + 2, o.y + y, 28, WOOD_DARK)
	# Shrine.
	o = _tile_base(atlas, 23, GRASS_MID, GRASS_LIGHT, GRASS_DARK, 5)
	_rect(atlas, o.x + 6, o.y + 7, 20, 23, INK)
	_rect(atlas, o.x + 8, o.y + 5, 16, 23, STONE_DARK)
	_rect(atlas, o.x + 10, o.y + 7, 12, 18, SHRINE_TEAL)
	_rect(atlas, o.x + 14, o.y + 10, 4, 11, WATER_LIGHT)
	_hline(atlas, o.x + 11, o.y + 14, 10, WATER_LIGHT)
	# Lily.
	o = _tile_base(atlas, 24, WATER_MID, WATER_LIGHT, WATER_DARK, 4)
	_rect(atlas, o.x + 8, o.y + 13, 16, 8, FOLIAGE_DARK)
	_rect(atlas, o.x + 10, o.y + 11, 12, 9, FOLIAGE_MID)
	_rect(atlas, o.x + 15, o.y + 14, 3, 3, FLOWER_RED)
	_tile_base(atlas, 25, MUD, DIRT, STONE_DARK, 18)
	# Corner path.
	o = _tile_base(atlas, 26, GRASS_MID, GRASS_LIGHT, GRASS_DARK, 7)
	for y in 24:
		for x in 24:
			if x > 9 or y < 12:
				_pixel(atlas, o.x + x, o.y + y, PATH_LIGHT if _hash(x, y, 26) % 11 == 0 else PATH_MID)
	# Tuft.
	o = _tile_base(atlas, 27, GRASS_MID, GRASS_LIGHT, GRASS_DARK, 6)
	for x in range(8, 25, 4):
		_vline(atlas, o.x + x, o.y + 15 - (x % 3), 8, FOLIAGE_DARK)
		_pixel(atlas, o.x + x + 1, o.y + 16, GRASS_LIGHT)
	# Stump.
	o = _tile_base(atlas, 28, GRASS_MID, GRASS_LIGHT, GRASS_DARK, 6)
	_rect(atlas, o.x + 8, o.y + 14, 16, 13, INK)
	_rect(atlas, o.x + 10, o.y + 13, 12, 12, WOOD_DARK)
	_rect(atlas, o.x + 11, o.y + 14, 10, 4, WOOD_MID)
	_hline(atlas, o.x + 13, o.y + 15, 6, PATH_LIGHT)
	# Steps.
	o = _tile_base(atlas, 29, STONE_DARK, STONE_MID, INK, 5)
	for y in range(4, 32, 7):
		_hline(atlas, o.x + 2, o.y + y, 28, STONE_LIGHT)
		_hline(atlas, o.x + 2, o.y + y + 2, 28, INK)
	# Flower patch.
	o = _tile_base(atlas, 30, GRASS_MID, GRASS_LIGHT, GRASS_DARK, 7)
	for p in [Vector2i(7, 8), Vector2i(15, 13), Vector2i(23, 7), Vector2i(10, 24), Vector2i(25, 21)]:
		_pixel(atlas, o.x + p.x, o.y + p.y, FLOWER_RED)
		_pixel(atlas, o.x + p.x + 1, o.y + p.y, FLOWER_YELLOW)
		_pixel(atlas, o.x + p.x, o.y + p.y + 1, FOLIAGE_DARK)
	# Signpost.
	o = _tile_base(atlas, 31, GRASS_MID, GRASS_LIGHT, GRASS_DARK, 6)
	_rect(atlas, o.x + 14, o.y + 14, 4, 17, INK)
	_rect(atlas, o.x + 15, o.y + 14, 2, 16, WOOD_DARK)
	_rect(atlas, o.x + 5, o.y + 7, 22, 11, INK)
	_rect(atlas, o.x + 7, o.y + 9, 18, 7, WOOD_MID)
	_hline(atlas, o.x + 10, o.y + 11, 9, PATH_LIGHT)
	_save(atlas, "tiles.png")


func _generate_characters() -> void:
	var characters: Array[Dictionary] = [
		{"name": "player", "cloth": CLOTH_A, "hair": HAIR_DARK, "accent": GOLD},
		{"name": "companion", "cloth": CLOTH_E, "hair": WOOD_DARK, "accent": WATER_LIGHT},
		{"name": "elder", "cloth": STONE_MID, "hair": STONE_LIGHT, "accent": CLOTH_D},
		{"name": "merchant", "cloth": CLOTH_C, "hair": WOOD_DARK, "accent": FLOWER_YELLOW},
		{"name": "rival", "cloth": CLOTH_B, "hair": HAIR_DARK, "accent": INK},
		{"name": "reeve", "cloth": CLOTH_D, "hair": STONE_DARK, "accent": GOLD},
		{"name": "mentor", "cloth": CLOTH_E, "hair": HAIR_DARK, "accent": SHRINE_TEAL},
		{"name": "warden", "cloth": CLOTH_C, "hair": HAIR_DARK, "accent": FOLIAGE_DARK},
		{"name": "marshal", "cloth": CLOTH_A, "hair": WOOD_DARK, "accent": FLOWER_RED},
	]
	for character in characters:
		var sheet := _new_image(256, 256)
		for direction in 4:
			for frame in 4:
				_draw_humanoid(sheet, Vector2i(frame * 64, direction * 64), frame, direction, character.cloth, character.hair, SKIN, character.accent)
		_save(sheet, "char_%s.png" % character.name)


func _draw_humanoid(image: Image, cell: Vector2i, frame: int, direction: int, cloth: Color, hair: Color, skin: Color, accent: Color) -> void:
	# Rows: DOWN, LEFT, RIGHT, UP. Frame 0 is neutral; 1/3 are opposite passing poses.
	var bob := 1 if frame == 2 else 0
	var swing := 0 if frame == 0 or frame == 2 else (-2 if frame == 1 else 2)
	var cx := cell.x + 32
	var top := cell.y + 9 + bob
	# Pixel-art shadow.
	_rect(image, cx - 12, cell.y + 56, 24, 3, STONE_DARK)
	_rect(image, cx - 9, cell.y + 55, 18, 2, RUBBLE)
	# Legs and outlined boots.
	var left_leg := swing
	var right_leg := -swing
	_rect(image, cx - 9 + left_leg, top + 38, 7, 12, INK)
	_rect(image, cx - 7 + left_leg, top + 38, 4, 10, cloth)
	_rect(image, cx + 2 + right_leg, top + 38, 7, 12, INK)
	_rect(image, cx + 3 + right_leg, top + 38, 4, 10, cloth)
	_rect(image, cx - 10 + left_leg, top + 47, 8, 4, HAIR_DARK)
	_rect(image, cx + 2 + right_leg, top + 47, 8, 4, HAIR_DARK)
	# Arms swing against legs.
	_rect(image, cx - 15 - swing, top + 27, 7, 15, INK)
	_rect(image, cx - 13 - swing, top + 29, 4, 10, cloth)
	_rect(image, cx + 8 + swing, top + 27, 7, 15, INK)
	_rect(image, cx + 9 + swing, top + 29, 4, 10, cloth)
	_pixel(image, cx - 11 - swing, top + 40, skin)
	_pixel(image, cx + 11 + swing, top + 40, skin)
	# Torso, collar/belt accent.
	_rect(image, cx - 10, top + 25, 20, 19, INK)
	_rect(image, cx - 8, top + 27, 16, 15, cloth)
	_hline(image, cx - 7, top + 31, 14, accent)
	_hline(image, cx - 8, top + 39, 16, WOOD_DARK)
	# Large outlined head.
	_rect(image, cx - 13, top + 2, 26, 25, INK)
	_rect(image, cx - 11, top + 4, 22, 21, skin)
	if direction == 3: # Back: hair covers the face.
		_rect(image, cx - 11, top + 4, 22, 17, hair)
		_rect(image, cx - 9, top + 20, 4, 5, hair)
		_rect(image, cx + 5, top + 20, 4, 5, hair)
	elif direction == 0:
		_rect(image, cx - 11, top + 4, 22, 8, hair)
		_rect(image, cx - 11, top + 10, 4, 7, hair)
		_rect(image, cx + 7, top + 10, 4, 7, hair)
		_rect(image, cx - 6, top + 16, 3, 3, INK)
		_rect(image, cx + 3, top + 16, 3, 3, INK)
		_hline(image, cx - 2, top + 22, 4, FLOWER_RED)
	else:
		# Profile faces point in genuinely opposite directions rather than reusing a frame.
		_rect(image, cx - 11, top + 4, 22, 9, hair)
		var face_side := -1 if direction == 1 else 1
		_rect(image, cx - 11 if face_side < 0 else cx + 7, top + 10, 4, 10, hair)
		_rect(image, cx - 7 if face_side < 0 else cx + 4, top + 16, 3, 3, INK)
		_pixel(image, cx - 12 if face_side < 0 else cx + 12, top + 19, skin)


func _generate_enemies() -> void:
	var beast := _new_image(64, 64)
	_rect(beast, 9, 51, 46, 4, STONE_DARK)
	# Tail, low body, four legs.
	_rect(beast, 5, 29, 13, 6, INK)
	_rect(beast, 7, 27, 11, 5, CLOTH_C)
	_rect(beast, 14, 25, 35, 24, INK)
	_rect(beast, 17, 27, 30, 18, WOOD_DARK)
	_rect(beast, 20, 29, 22, 7, DIRT)
	for x in [18, 28, 39, 45]:
		_rect(beast, x, 43, 5, 10, INK)
		_rect(beast, x + 1, 43, 3, 7, WOOD_DARK)
	_rect(beast, 42, 17, 17, 22, INK)
	_rect(beast, 44, 20, 13, 17, DIRT)
	_rect(beast, 43, 14, 6, 10, INK)
	_rect(beast, 52, 14, 6, 10, INK)
	_pixel(beast, 47, 26, FLOWER_YELLOW)
	_pixel(beast, 54, 26, FLOWER_YELLOW)
	_pixel(beast, 47, 27, INK)
	_pixel(beast, 54, 27, INK)
	_pixel(beast, 48, 36, PARCHMENT)
	_pixel(beast, 53, 36, PARCHMENT)
	_save(beast, "enemy_beast.png")

	_draw_bandit("bandit", false)
	_draw_bandit("bandit_leader", true)


func _draw_bandit(name: String, leader: bool) -> void:
	var image := _new_image(64, 64)
	var scale_add := 2 if leader else 0
	_rect(image, 15, 55, 36, 3, STONE_DARK)
	# Legs and torso.
	_rect(image, 22 - scale_add, 42, 8, 14, INK)
	_rect(image, 34, 42, 8 + scale_add, 14, INK)
	_rect(image, 17 - scale_add, 25, 30 + scale_add * 2, 23, INK)
	_rect(image, 20 - scale_add, 28, 24 + scale_add * 2, 17, CLOTH_B if leader else CLOTH_C)
	_hline(image, 20 - scale_add, 36, 24 + scale_add * 2, FLOWER_RED if leader else WOOD_DARK)
	# Head, mask, eyes.
	_rect(image, 20 - scale_add, 8 - scale_add, 24 + scale_add * 2, 22 + scale_add, INK)
	_rect(image, 23 - scale_add, 11 - scale_add, 18 + scale_add * 2, 16 + scale_add, SKIN)
	_rect(image, 21 - scale_add, 8 - scale_add, 22 + scale_add * 2, 8, HAIR_DARK)
	_rect(image, 22 - scale_add, 19, 20 + scale_add * 2, 7, HAIR_DARK)
	_pixel(image, 27, 18, PARCHMENT)
	_pixel(image, 37, 18, PARCHMENT)
	# Blade with dark pixel edge.
	for i in 18:
		_rect(image, 48 + i / 5, 20 + i, 4, 2, INK)
		_rect(image, 49 + i / 5, 20 + i, 2, 1, STONE_LIGHT)
	_rect(image, 46, 37, 10, 4, GOLD)
	_save(image, "enemy_%s.png" % name)


func _generate_ui() -> void:
	# 9-slice panel: 8 px fixed border/corners; safe content margin is 10 px.
	var panel := _new_image(48, 48, PARCHMENT)
	_rect(panel, 0, 0, 48, 3, INK)
	_rect(panel, 0, 45, 48, 3, INK)
	_rect(panel, 0, 0, 3, 48, INK)
	_rect(panel, 45, 0, 3, 48, INK)
	_rect(panel, 3, 3, 42, 3, WOOD_DARK)
	_rect(panel, 3, 42, 42, 3, WOOD_DARK)
	_rect(panel, 3, 3, 3, 42, WOOD_DARK)
	_rect(panel, 42, 3, 3, 42, WOOD_DARK)
	for p in [Vector2i(6, 6), Vector2i(39, 6), Vector2i(6, 39), Vector2i(39, 39)]:
		_rect(panel, p.x, p.y, 3, 3, GOLD)
	for y in range(11, 39, 8):
		_pixel(panel, 12 + (_hash(y, 1) % 22), y, PATH_LIGHT)
	_save(panel, "ui/panel.png")

	var bar := _new_image(64, 8, INK)
	_rect(bar, 2, 2, 60, 4, STONE_DARK)
	_pixel(bar, 1, 1, STONE_LIGHT)
	_pixel(bar, 62, 1, STONE_LIGHT)
	_save(bar, "ui/bar_frame.png")
	_save(_new_image(1, 4, BAR_RED), "ui/hp_fill.png")
	_save(_new_image(1, 4, BAR_BLUE), "ui/qi_fill.png")

	var prompt := _new_image(24, 24)
	_rect(prompt, 3, 2, 18, 20, INK)
	_rect(prompt, 5, 4, 14, 16, PARCHMENT)
	_rect(prompt, 8, 7, 9, 3, INK)
	_rect(prompt, 8, 10, 3, 8, INK)
	_rect(prompt, 8, 15, 9, 3, INK)
	_rect(prompt, 11, 11, 5, 2, INK)
	_save(prompt, "ui/prompt_e.png")

	var cursor := _new_image(16, 16)
	for x in range(2, 12):
		var half_height := mini(x - 1, 11 - x)
		for y in range(8 - half_height, 9 + half_height):
			_pixel(cursor, x, y, INK)
	for x in range(3, 10):
		var half_height := mini(x - 2, 10 - x)
		for y in range(8 - half_height, 9 + half_height):
			_pixel(cursor, x, y, GOLD)
	_save(cursor, "ui/cursor.png")


func _write_manifest() -> void:
	var notes := {
		"tiles.png": "32-tile atlas; 32 px cells in an 8×4 grid.",
		"ui/panel.png": "48×48 9-slice panel; 8 px slice border and 10 px content margin.",
		"ui/bar_frame.png": "Stretchable 64×8 bar frame; 2 px inset.",
		"ui/hp_fill.png": "One-pixel-wide stretchable HP fill.",
		"ui/qi_fill.png": "One-pixel-wide stretchable qi fill.",
		"ui/prompt_e.png": "24×24 interaction keycap.",
		"ui/cursor.png": "16×16 menu selector arrow.",
	}
	var text := "# Asset Manifest\n\nThis gates future replacement when the owner picks real art direction; all entries are CC0.\n\n"
	text += "| File | Source | License | Date | Note |\n|---|---|---|---|---|\n"
	for entry in _written:
		var relative: String = String(entry.path).trim_prefix(OUTPUT_DIR + "/")
		var note: String = notes.get(relative, "Self-authored cohesive DS-era placeholder.")
		text += "| `generated/%s` | authored/generated by `tools/gen_assets.gd` | CC0 / public-domain (self-authored) | 2026-07-10 | %s |\n" % [relative, note]
	var manifest := FileAccess.open("res://game/assets/ASSET-MANIFEST.md", FileAccess.WRITE)
	if manifest == null:
		push_error("Could not write asset manifest")
		return
	manifest.store_string(text)
