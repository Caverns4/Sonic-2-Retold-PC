extends StaticBody2D

@export var power = 480
var bounceSound = preload("res://Audio/SFX/Objects/CNZ_BigBumper.wav")

#When a body(player) enters the area and it not controlled by an outside object,
#Bounce off based on the angle of the player relative to the object.

func physics_collision(body, hitVector):
	var col = body.objectCheck.get_collision_normal()
	#print(col)
	
	if col:
		body.movement = (col.normalized()*power)
	else:
		if abs(body.global_position.x - global_position.x) < 30:
			body.movement.y = power*sign(body.global_position.y - global_position.y)
		else:
			body.movement.x = -power/2*sign(global_scale.x)
	
	if body.currentState == body.STATES.JUMP: # set the state to air
		body.set_state(body.STATES.AIR)
	
	SoundDriver.play_sound(bounceSound)
