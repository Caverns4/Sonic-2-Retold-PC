class_name SavePopupMenu
extends GeneralPopUpMenu

var save_file_id: int = 0
var save_data: Array = []
var selection_id: int = 0
var level_select_id: int = 0

@onready var query_text : Label = $Panel/NinePatchRect/QueryText
@onready var char_select : Sprite2D = $Panel/NinePatchRect/PlayerSprites
@onready var level_select : Sprite2D = $Panel/NinePatchRect/LevelBanner/LevelIcon
@onready var param_text : Label = $Panel/NinePatchRect/ParamText
@onready var left_button : Button = $Panel/NinePatchRect/Control/LeftButton
@onready var right_button : Button = $Panel/NinePatchRect/Control/RightButton
@onready var accept_button : Button = $Panel/NinePatchRect/Control/AcceptButton
@onready var cancel_button : Button = $Panel/NinePatchRect/Control/CancelButton

func _ready() -> void:
	SoundDriver.play_sound(sfx_select)
	if !save_file_id:
		query_text.text = "Play without\nsaving"
		level_select.get_parent().queue_free()
	elif save_data:
		char_select.queue_free()
		query_text.text = "Continue file " + str(save_file_id) + "?"
		selection_id = save_data[3]
		if !save_data[3] == Global.ZONES.ENDING:
			left_button.disabled = true
			right_button.disabled = true
			#left_button.queue_free()
			#right_button.queue_free()
		level_select.frame = selection_id
		print(GlobalFunctions.get_chaos_emerald_count(save_data[4]))
	else:
		level_select.get_parent().queue_free()
		query_text.text = "Select character\nfor file " + str(save_file_id)
		print(GlobalFunctions.get_chaos_emerald_count(0))
	accept_button.grab_focus()


var normal_zones = [
	Global.ZONES.EMERALD_HILL,
	Global.ZONES.HILL_TOP,
	Global.ZONES.DUST_HILL,
	Global.ZONES.HIDDEN_PALACE,
	Global.ZONES.CASINO_NIGHT,
	Global.ZONES.METROPOLIS,
]

func update_level_select(direction: int = 0):
	if save_data[3] == Global.ZONES.ENDING:
		@warning_ignore("int_as_enum_without_cast")
		level_select_id = wrapi(selection_id + direction,
		0,normal_zones.size()) as Global.ZONES
	selection_id = normal_zones[level_select_id]
	level_select.frame = selection_id

func _on_cancel_button_pressed() -> void:
	disable_buttons()
	SoundDriver.play_sound(sfx_cancel)
	close_menu(-1)

func _on_accept_button_pressed() -> void:
	disable_buttons()
	SoundDriver.play_sound(sfx_confirm)
	if save_data and selection_id == Global.ZONES.ENDING:
		selection_id = Global.ZONES.EMERALD_HILL
	close_menu(selection_id)


func _on_left_button_pressed() -> void:
	if !save_data:
		selection_id = wrapi(selection_id-1,0,Global.PLAYER_MODES.size())
		char_select.frame = selection_id
		param_text.text = Global.playerModes[selection_id]
	else:
		update_level_select(-1)


func _on_right_button_pressed() -> void:
	if !save_data:
		selection_id = wrapi(selection_id+1,0,Global.PLAYER_MODES.size())
		char_select.frame = selection_id
		param_text.text = Global.playerModes[selection_id]
	else:
		update_level_select(1)

func disable_buttons():
	accept_button.disabled = true
	cancel_button.disabled = true
	if left_button:
		left_button.disabled = true
		right_button.disabled = true
	
