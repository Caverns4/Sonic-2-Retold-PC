extends GeneralPopUpMenu

@onready var query_text : Label = $Panel/NinePatchRect/QueryText
@onready var eggman: AnimatedSprite2D = $Panel/NinePatchRect/EggmanIcon
@onready var del_button: Button = $Panel/NinePatchRect/DeleteButton
@onready var cancel_button: Button = $Panel/NinePatchRect/CancelButton

func _ready() -> void:
	SoundDriver.play_sound(sfx_select)
	cancel_button.grab_focus()

func _on_cancel_button_pressed() -> void:
	SoundDriver.play_sound(sfx_cancel)
	del_button.disabled = true
	cancel_button.disabled = true
	close_menu(-1)


func _on_delete_button_pressed() -> void:
	SoundDriver.play_sound(sfx_confirm)
	del_button.disabled = true
	cancel_button.disabled = true
	eggman.play("delete")
	await get_tree().create_timer(1.0).timeout
	close_menu(1)
