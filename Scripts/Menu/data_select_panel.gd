class_name DataSelectPanel
extends Button

var character_id: int = 0
var level_id: Global.ZONES = Global.ZONES.EMERALD_HILL

var save_game_id: int = 0:
	set(value):
		save_game_id = value
		data = Global.LoadSaveGameSlotData(save_game_id)
	
var data: Array = []:
	set(value):
		data = value
		_update_save_preview()

signal press(saved_game_id)

func _update_save_preview():
	pass

func _on_pressed() -> void:
	press.emit(save_game_id)
