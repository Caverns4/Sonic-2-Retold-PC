class_name DataSelectPanel
extends Node2D

@export var character_id: Global.PLAYER_MODES = 0 as Global.PLAYER_MODES

var save_game_id: int = 0
var selected: bool = true
var data: Array = []

@onready var text_label = $DataBox/Label

## Called when this menu item's selection state changes.
func update_selection_state(state: bool) -> void:
	if state:
		$DataBox.modulate = Color.YELLOW
	else:
		$DataBox.modulate = Color.WHITE

## When input is given on this child.
func update_menu_item(_direction: int = 0):
	return false

## When the Action or start button is pressed on this item 
func use() -> bool:
	return false
