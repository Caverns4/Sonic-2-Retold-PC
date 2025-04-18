extends StaticBody2D

var bounceSound = preload("res://Audio/SFX/Objects/CNZ_BigBumper.wav")

#When a body(player) enters the area and it not controlled by an outside object,
#Bounce off based on the angle of the player relative to the object.

func physics_collision(body, hitVector):
	#Placeholder until I write a better method
	#body.movement = (body.global_position-global_position).normalized()*7*60.0
	
	#body.movement = (hitVector.rotated(rad_to_deg(180.0)).normalized()*60.0
	#+ Vector2(0,-480).rotated(rotation))
	body.movement = (hitVector.rotated(rad_to_deg(180.0)).normalized()*120.0
	+ (Vector2(0,-480).rotated(global_rotation)))
	
	if body.currentState == body.STATES.JUMP: # set the state to air
		body.set_state(body.STATES.AIR)
	
	Global.play_sound(bounceSound)
