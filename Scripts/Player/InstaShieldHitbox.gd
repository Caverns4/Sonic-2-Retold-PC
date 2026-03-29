extends Area2D

@onready var parent: Player2D = get_parent().get_parent()

func is_attacking() -> bool:
	if !$HitBox.disabled:
		return true
	return parent.is_attacking()
