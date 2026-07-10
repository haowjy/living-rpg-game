class_name NpcDef
extends Resource
## Authored definition of an overworld NPC.
##
## Dialogue lives in game/data/dialogue_data.gd keyed by npc id, because
## branching dialogue as nested exported Dictionaries is hard to author
## and review; code reads better in diffs.

@export var id: String = ""
@export var display_name: String = ""
## Short role label shown under the name, e.g. "quest giver".
@export var role: String = ""
## Item ids this NPC offers for sale when acting as a merchant.
@export var goods: PackedStringArray = PackedStringArray()
@export var body_color: Color = Color(0.8, 0.7, 0.3)
