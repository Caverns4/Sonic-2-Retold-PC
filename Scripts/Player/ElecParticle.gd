extends Node2D

var speed: float = 3
var direction: Vector2 = Vector2.RIGHT

func _process(delta: float) -> void:
	translate(direction*speed)
	if (speed > 0):
		speed -= delta*10
	else:
		queue_free()
