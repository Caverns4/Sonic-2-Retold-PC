extends ColorRect

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var cam: Camera2D = get_viewport().get_camera_2d()
	global_position.x = cam.global_position.x - 480
