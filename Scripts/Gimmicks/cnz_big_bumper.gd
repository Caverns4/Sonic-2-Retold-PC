extends StaticBody2D

#When a body(player) enters the area and it not controlled by an outside object,
#Bounce off based on the angle of the player relative to the object.

func physics_collision(body, _hitVector):
	#Placeholder until I write a better method
	body.movement = (body.global_position-global_position).normalized()*7*60.0
	
	if body.currentState == body.STATES.JUMP: # set the state to air
		body.set_state(body.STATES.AIR)
	
	Global.play_sound("res://Audio/SFX/Objects/CNZ_BigBumper.wav")
