extends EnemyBase



func _physics_process(delta: float) -> void:
	var test = GlobalFunctions.get_orientation_to_player(global_position)
	if test.length() < 96:
		destroy()
	
	move_and_slide()
