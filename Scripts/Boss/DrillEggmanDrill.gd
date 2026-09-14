extends "res://Scripts/Objects/Hazard.gd"

var direction: int = -1
var is_free: bool = false

func _physics_process(delta: float) -> void:
	if is_free:
		global_position.x += (180 * direction * delta)
