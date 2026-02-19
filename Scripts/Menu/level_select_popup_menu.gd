extends GeneralPopUpMenu

@onready var level_icon: Sprite2D = $Panel/NinePatchRect/LevelBanner/LevelIcon
@onready var level_name: Label = $Panel/NinePatchRect/ParamText
@onready var left_button : Button = $Panel/NinePatchRect/Control/LeftButton
@onready var right_button : Button = $Panel/NinePatchRect/Control/RightButton
@onready var accept_button : Button = $Panel/NinePatchRect/Control/AcceptButton
@onready var cancel_button : Button = $Panel/NinePatchRect/Control/CancelButton


var selection_id: int = 0

func _ready() -> void:
	SoundDriver.play_sound(sfx_select)
	update_preview(0)
	accept_button.grab_focus()

func update_preview(direction: int):
	selection_id = wrapi(selection_id + direction,0,Global.zone_names.size()-1)
	level_icon.frame = selection_id
	level_name.text = Global.zone_names[selection_id]



func _on_left_button_pressed() -> void:
	update_preview(-1)


func _on_right_button_pressed() -> void:
	update_preview(1)


func _on_accept_button_pressed() -> void:
	SoundDriver.play_sound(sfx_confirm)
	close_menu(selection_id)


func _on_cancel_button_pressed() -> void:
	SoundDriver.play_sound(sfx_cancel)
	close_menu(-1)
