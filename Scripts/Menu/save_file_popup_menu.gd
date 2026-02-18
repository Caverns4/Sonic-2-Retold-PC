class_name SavePopupMenu
extends GeneralPopUpMenu

var save_file_id: int = 0
var save_data: Array = []
var character_selection: int = 0

@onready var query_text : Label = $Panel/NinePatchRect/QueryText
@onready var char_select : Sprite2D = $Panel/NinePatchRect/PlayerSprites
@onready var level_select : Sprite2D = $Panel/NinePatchRect/LevelBanner/LevelIcon
@onready var param_text : Label = $Panel/NinePatchRect/ParamText
@onready var left_button : Button = $Panel/NinePatchRect/LeftButton
@onready var right_button : Button = $Panel/NinePatchRect/RightButton


func _ready() -> void:
	if !save_file_id:
		query_text.text = "Play without\nsaving"
		level_select.get_parent().queue_free()
		if Global.level_select_flag:
			$Panel/NinePatchRect/AcceptButton/Label.text = "select\nlevel"
	elif save_data:
		char_select.queue_free()
		left_button.queue_free()
		right_button.queue_free()
		query_text.text = "Continue file " + str(save_file_id) + "?"
		
		print(GlobalFunctions.get_chaos_emerald_count(save_data[4]))
	else:
		level_select.get_parent().queue_free()
		query_text.text = "Select character\nfor slot " + str(save_file_id)
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


func _on_left_button_pressed() -> void:
	if !save_data:
		character_selection = wrapi(character_selection-1,0,Global.PLAYER_MODES.size())
		char_select.frame = character_selection
		param_text.text = Global.playerModes[character_selection]


func _on_right_button_pressed() -> void:
	if !save_data:
		character_selection = wrapi(character_selection+1,0,Global.PLAYER_MODES.size())
		char_select.frame = character_selection
		param_text.text = Global.playerModes[character_selection]
