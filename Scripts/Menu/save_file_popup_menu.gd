class_name SavePopupMenu
extends GeneralPopUpMenu

var save_file_id: int = 0
var save_data: Array = []
var character_selection: int = 0

@onready var query_text : Label = $Panel/NinePatchRect/QueryText

func _ready() -> void:
	if !save_file_id:
		query_text.text = "Play without\nsaving?"
		print(GlobalFunctions.get_chaos_emerald_count(0))
	elif save_data:
		query_text.text = "Continue file " + str(save_file_id) + "?"
		print(GlobalFunctions.get_chaos_emerald_count(save_data[4]))
	else:
		query_text.text = "Create save file\nin slot " + str(save_file_id) + "?"
		print(GlobalFunctions.get_chaos_emerald_count(0))


func _on_cancel_button_pressed() -> void:
	SoundDriver.play_sound(sfx_cancel)
	close_menu(-1)

func _on_accept_button_pressed() -> void:
	SoundDriver.play_sound(sfx_confirm)
	if save_data:
		close_menu(save_file_id)
	else:
		close_menu(character_selection)
