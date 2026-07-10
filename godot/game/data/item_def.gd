class_name ItemDef
extends Resource
## Authored definition of an inventory item.

@export var id: String = ""
@export var display_name: String = ""
## Supported values: "consumable" and "spirit_contract".
@export var kind: String = ""
@export var price: int = 0
@export var heal_hp: int = 0
