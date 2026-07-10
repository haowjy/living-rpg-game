class_name CombatPortraitCatalog
extends RefCounted
## The single mapping from sim combatant ids to battle presentation textures.

const GENERATED := "res://game/assets/generated/"
const ALIASES := {
	"companion_a": "char_companion.png",
	"monster_a": "enemy_beast.png",
	"monster_b": "enemy_bandit.png",
	"monster_b_leader": "enemy_bandit_leader.png",
}


static func resolve(combatant: Combatant) -> Texture2D:
	var asset_id := combatant.id.get_slice("#", 0)
	var filename := "%s_%s.png" % ["enemy" if combatant.is_enemy else "char", asset_id]
	if ALIASES.has(asset_id):
		filename = ALIASES[asset_id]
	var texture := load(GENERATED + filename) as Texture2D \
			if ResourceLoader.exists(GENERATED + filename) else null
	if texture == null:
		return _visible_fallback()
	if combatant.is_enemy or combatant.is_spirit():
		return texture
	var portrait := AtlasTexture.new()
	portrait.atlas = texture
	portrait.region = Rect2(0, 0, texture.get_width() / 4.0, texture.get_height() / 4.0)
	return portrait


static func _visible_fallback() -> Texture2D:
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color("292d35"))
	for y in 32:
		for x in 32:
			if int(x / 8 + y / 8) % 2 == 0:
				image.set_pixel(x, y, Color("c5984c"))
	return ImageTexture.create_from_image(image)
