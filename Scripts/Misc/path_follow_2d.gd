extends PathFollow2D

@export var speed: float = 8.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress += delta*speed
