extends StaticBody2D

var bumperCount = 0


func physics_collision(body, _hitVector):
	# on collision bump the player away and play animation, pretty simple
	body.movement = (body.global_position-global_position).normalized()*7*60.0
	
	if body.currentState == body.STATES.JUMP: # set the state to air
		body.set_state(body.STATES.AIR)
	
	$Bumper.play("default")
	
	Global.play_sound($BumperSFX.stream)
	# score counter
	if bumperCount < 10:
		Global.add_score(global_position,0)
		bumperCount += 1
