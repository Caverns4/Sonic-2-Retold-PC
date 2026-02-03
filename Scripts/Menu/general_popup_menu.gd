class_name GeneralPopUpMenu
extends Control

@onready var animator: AnimationPlayer = $AnimationPlayer

var pass_var
signal menu_exit(pass_var)

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
