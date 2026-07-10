class_name ContentDB
extends RefCounted
## Loads and indexes all authored content resources at boot.
##
## Content lives as .tres files under res://game/data/content/.
## Everything is indexed by its `id` property. Fails loudly on
## duplicate or missing ids so authoring mistakes surface immediately.

const CONTENT_DIR := "res://game/data/content"

var techniques: Dictionary = {}
var spirits: Dictionary = {}
var enemies: Dictionary = {}
var areas: Dictionary = {}
var npcs: Dictionary = {}
var encounters: Dictionary = {}
var items: Dictionary = {}


func _init() -> void:
	_load_dir(CONTENT_DIR)


func _load_dir(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("ContentDB: cannot open content dir: %s" % path)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			_load_dir(path.path_join(file_name))
		elif file_name.ends_with(".tres"):
			_register(load(path.path_join(file_name)))
		file_name = dir.get_next()
	dir.list_dir_end()


func _register(res: Resource) -> void:
	if res is TechniqueDef:
		_index(techniques, res, res.id)
	elif res is SpiritDef:
		_index(spirits, res, res.id)
	elif res is EnemyDef:
		_index(enemies, res, res.id)
	elif res is AreaDef:
		_index(areas, res, res.id)
	elif res is NpcDef:
		_index(npcs, res, res.id)
	elif res is EncounterDef:
		_index(encounters, res, res.id)
	elif res is ItemDef:
		_index(items, res, res.id)
	else:
		push_error("ContentDB: unknown resource type: %s" % res)


func _index(table: Dictionary, res: Resource, id: String) -> void:
	assert(id != "", "ContentDB: resource with empty id: %s" % res.resource_path)
	assert(not table.has(id), "ContentDB: duplicate id: %s" % id)
	table[id] = res


func technique(id: String) -> TechniqueDef:
	assert(techniques.has(id), "Unknown technique id: %s" % id)
	return techniques[id]


func spirit(id: String) -> SpiritDef:
	assert(spirits.has(id), "Unknown spirit id: %s" % id)
	return spirits[id]


func enemy(id: String) -> EnemyDef:
	assert(enemies.has(id), "Unknown enemy id: %s" % id)
	return enemies[id]


func area(id: String) -> AreaDef:
	assert(areas.has(id), "Unknown area id: %s" % id)
	return areas[id]


func npc(id: String) -> NpcDef:
	assert(npcs.has(id), "Unknown npc id: %s" % id)
	return npcs[id]


func encounter(id: String) -> EncounterDef:
	assert(encounters.has(id), "Unknown encounter id: %s" % id)
	return encounters[id]


func item(id: String) -> ItemDef:
	assert(items.has(id), "Unknown item id: %s" % id)
	return items[id]
