extends "res://Scripts/Objects/Hazard.gd"

var direction = -1
var free = false

func _physics_process(delta):
	if free:
		global_position.x += (200 * direction * delta)
	pass
