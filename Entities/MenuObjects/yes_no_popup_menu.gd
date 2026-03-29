class_name YesNoPopUpMenu
extends GeneralPopUpMenu

## The name of the Slider
var question: String = ""
var start_on_yes: bool = true

@onready var title_label: Label = $Panel/NinePatchRect/MenuOptions/Question

func  _ready() -> void:
	SoundDriver.play_sound(sfx_select)
	title_label.text = question
	if start_on_yes:
		$Panel/NinePatchRect/MenuOptions/AcceptButton.grab_focus()
	else:
		$Panel/NinePatchRect/MenuOptions/CancelButton.grab_focus()
	

func _on_accept_button_pressed() -> void:
	close_menu(true)
	SoundDriver.play_sound(sfx_confirm)


func _on_cancel_button_pressed() -> void:
	close_menu(false)
	SoundDriver.play_sound(sfx_cancel)
