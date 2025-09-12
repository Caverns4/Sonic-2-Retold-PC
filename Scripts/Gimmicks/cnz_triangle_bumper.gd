extends StaticBody2D

@export var power = 480
var bounceSound = preload("res://Audio/SFX/Objects/CNZ_BigBumper.wav")

#When a body(player) enters the area and it not controlled by an outside object,
#Bounce off based on the angle of the player relative to the object.

func physics_collision(body, hitVector):
	var col = body.objectCheck.get_collision_normal()
	if col:
		body.movement = (col.normalized()*power)
	else:
		var posedif = body.global_position - global_position
		posedif = posedif.normalized()
		#print(posedif)
		if posedif.y > abs(posedif.x):
			body.movement.y = 60
		#else:
		#	body.movement.x = -power/2*sign(0-posedif.x)
	body.set_state(body.STATES.AIR)
	body.angle = 0
	body.ground = false
	if body.currentState == body.STATES.JUMP: # set the state to air
		body.set_state(body.STATES.AIR)
	SoundDriver.play_sound(bounceSound)
