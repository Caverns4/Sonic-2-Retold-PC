extends StaticBody2D

func physics_collision(body, _hitVector):
	# on collision bump the player away and play animation, pretty simple
	body.movement = (body.global_position-global_position).normalized()*3*60.0
	
	if body.currentState == body.STATES.JUMP: # set the state to air
		body.set_state(body.STATES.AIR)

	Global.play_sound($BumperSFX.stream)
