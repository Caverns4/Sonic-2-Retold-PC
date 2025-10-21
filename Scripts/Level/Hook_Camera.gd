extends Node2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var xSize = get_viewport_rect().size.x/2
	var ySize = get_viewport_rect().size.y/2
	
	for i in Global.players:
		var player: Player2D = i
		player.limitLeft = (global_position.x - xSize)
		player.limitRight = (global_position.x + xSize)
		#i.limitBottom = (global_position.y + ySize)
		#i.limitTop = (global_position.y - ySize)
		
		player.camera.limit_left = int(global_position.x - xSize)
		player.camera.limit_right = int(global_position.x + xSize)
		player.camera.limit_bottom = int(global_position.y + ySize)
		player.camera.limit_top = int(global_position.y - ySize)
		player.global_position.x = clampf(
			player.global_position.x,
			global_position.x - xSize + 24,
			global_position.x + xSize - 24)
		#player.global_position.y = clampf(
		#	player.global_position.y,
		#	global_position.y - ySize + 24,
		#	global_position.y + ySize - 24)
