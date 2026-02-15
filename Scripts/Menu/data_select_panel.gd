class_name DataSelectPanel
extends Button

@export var character_id: Global.PLAYER_MODES = 0 as Global.PLAYER_MODES

var save_game_id: int = 0:
	set(value):
		save_game_id = value
		_update_save_preview()
	
var data: Array = []

signal press(saved_game_id)

func _update_save_preview():
	pass

func _on_pressed() -> void:
	press.emit(save_game_id)
