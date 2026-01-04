extends Node

@export var next_scene: String = "res://Scene/Presentation/PoweredByWorlds.tscn"

func _ready() -> void:
	$CanvasLayer/HBoxContainer/YesButton.grab_focus()


func _on_yes_button_pressed() -> void:
	if Main.crt_filter.visible:
		Main.change_scene(next_scene,"",0.0)
	else:
		Main.crt_filter.show()
		


func _on_no_button_pressed() -> void:
	if Main.crt_filter.visible:
		Main.crt_filter.hide()
	else:
		Main.change_scene(next_scene,"",0.0)
