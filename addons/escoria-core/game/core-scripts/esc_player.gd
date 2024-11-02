@tool
@icon("res://addons/escoria-core/design/esc_player.svg")
# A playable character
extends ESCItem
class_name ESCPlayer




# Whether the player can be selected like an item
@export var selectable: bool = false


# A player is always movable
func _init():
	is_movable = true
	_force_registration = true


# Ready function
func _ready():
	if selectable or is_movable:
		super()
	else:
		tooltip_name = ""
