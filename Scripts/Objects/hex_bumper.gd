extends StaticBody2D

@export var power: float = 360

func physics_collision(body, _hitVector):
	var col = body.objectCheck.get_collision_normal()
	if col:
		body.movement = (col.normalized()*power)
		#body.movement = (hitVector.rotated(rad_to_deg(180.0)).normalized()*(power/4)
		#+ (Vector2(0,-power).rotated(global_rotation)))
	#else:
	#	body.movement = Vector2.UP.rotated(global_rotation)*power
	$BumperSFX.play()
