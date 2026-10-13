class_name PlayerState extends Node

@onready var parent: Player2D = get_parent().get_parent()

# Override this to take an action on entering the state
func state_enter() -> void:
	pass

# Override this to take an action on exiting the state
func state_exit() -> void:
	pass
