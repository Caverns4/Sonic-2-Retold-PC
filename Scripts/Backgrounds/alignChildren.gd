extends ParallaxLayer

func _physics_process(delta: float) -> void:
	for i in get_children(true):
		i.global_position.x = round(global_position.x)
		i.global_position.y = round(global_position.y)
