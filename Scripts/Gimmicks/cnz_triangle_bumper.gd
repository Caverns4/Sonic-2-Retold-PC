extends StaticBody2D

@export var power = 480
var bounceSound = preload("res://Audio/SFX/Objects/CNZ_BigBumper.wav")

#When a body(player) enters the area and it not controlled by an outside object,
#Bounce off based on the angle of the player relative to the object.

func physics_collision(body: Player2D, _hitVector):
	var bounce: bool = false
	
	var col = body.objectCheck.get_collision_normal()
	if col and (col.x != 0 and col.y != 0):
		body.movement = (col.normalized()*power)
		bounce = true
	else:
		var posedif = body.global_position - global_position
		if posedif.y > 0 and abs(posedif.x) < 32 and body.movement.y <= 0:
			body.movement.y = 60
			bounce = true
	if bounce:
		body.set_state(body.STATES.AIR)
		body.angle = 0
		body.ground = false
		if body.currentState == body.STATES.JUMP: # set the state to air
			body.set_state(body.STATES.AIR)
		SoundDriver.play_sound(bounceSound)
