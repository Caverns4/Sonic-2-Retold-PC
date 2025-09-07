extends Node2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var xSize = get_viewport_rect().size.x/2
	var ySize = get_viewport_rect().size.y/2
	
	for i in Global.players:
		i.limitLeft = (global_position.x - xSize)
		i.limitRight = (global_position.x + xSize)
		#i.limitBottom = (global_position.y + ySize)
		#i.limitTop = (global_position.y - ySize)
		
		i.camera.limit_left = (global_position.x - xSize)
		i.camera.limit_right = (global_position.x + xSize)
		i.camera.limit_bottom = (global_position.y + ySize)
		i.camera.limit_top = (global_position.y - ySize)
		i.global_position.x = clampi(
			i.global_position.x,
			global_position.x - xSize + 24,
			global_position.x + xSize - 24)
