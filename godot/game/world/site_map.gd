class_name SiteMap
extends Resource
## Authored, serializable description of one tile-based site.

@export var id: String = ""
@export var ground_rows: PackedStringArray = PackedStringArray()
@export var overlay_rows: PackedStringArray = PackedStringArray()
@export var placements: Array[Dictionary] = []


func size() -> Vector2i:
	if ground_rows.is_empty():
		return Vector2i.ZERO
	return Vector2i(ground_rows[0].length(), ground_rows.size())
