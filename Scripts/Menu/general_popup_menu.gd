class_name GeneralPopUpMenu
extends Control

@onready var animator: AnimationPlayer = $AnimationPlayer

var sfx_select = preload("res://Audio/SFX/Misc/MenuWoosh.wav")
var sfx_confirm = preload("res://Audio/SFX/Misc/MenuAccept.wav")
var sfx_cancel = preload("res://Audio/SFX/Misc/MenuBleep.wav")

var pass_var
signal menu_exit(pass_var)

func _ready() -> void:
	SoundDriver.play_sound(sfx_select)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'enter':
		activate_menu()
		animator.play("RESET")
	if anim_name == 'exit':
		menu_exit.emit(pass_var)
		queue_free()

func activate_menu():
	pass

func close_menu(variant):
	pass_var = variant
	animator.play("exit")
