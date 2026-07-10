class_name AreaDef
extends Resource
## Authored definition of a walkable overworld area.

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
## Whether traveling between this area and another time-advancing area costs time.
@export var advances_time: bool = true
## Area ids reachable from here. Order controls exit placement
## (index 0 = west edge, 1 = east, 2 = north, 3 = south).
@export var exits: PackedStringArray = PackedStringArray()
## Npc ids standing in this area.
@export var npc_ids: PackedStringArray = PackedStringArray()
## Encounter id triggered by this area's fight interactable, "" for none.
@export var encounter_id: String = ""
## Background tint for the placeholder art.
@export var floor_color: Color = Color(0.18, 0.2, 0.16)
