class_name GeneralPopUpMenu
extends Control

@onready var animator: AnimationPlayer = $AnimationPlayer

var sfx_select: AudioStream = preload("res://Audio/SFX/Misc/MenuWoosh.wav")
var sfx_confirm: AudioStream = preload("res://Audio/SFX/Misc/MenuAccept.wav")
var sfx_cancel: AudioStream = preload("res://Audio/SFX/Misc/MenuBleep.wav")

var pass_var: Variant
signal menu_exit(pass_var: Variant)

func _ready() -> void:
	SoundDriver.play_sound(sfx_select)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'enter':
		activate_menu()
		animator.play("RESET")
	if anim_name == 'exit':
		menu_exit.emit(pass_var)
		queue_free()

func activate_menu() -> void:
	pass

func close_menu(variant: Variant) -> void:
	pass_var = variant
	animator.play("exit")
