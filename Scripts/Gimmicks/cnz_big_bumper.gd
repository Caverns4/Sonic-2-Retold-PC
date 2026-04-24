extends StaticBody2D

@export var power: float = 480
var bounceSound: AudioStream = preload("res://Audio/SFX/Objects/CNZ_BigBumper.wav")

#When a body(player) enters the area and it not controlled by an outside object,
#Bounce off based on the angle of the player relative to the object.

func physics_collision(body: Player2D, hitVector: Vector2) -> void:
	var col: Vector2 = body.objectCheck.get_collision_normal()
	if col:
		body.movement = (hitVector.rotated(rad_to_deg(180.0)).normalized()*(power/4)
		+ (Vector2(0,-power).rotated(global_rotation)))
	else:
		body.movement = Vector2.UP.rotated(global_rotation)*power
	body.set_state(body.STATES.AIR)
	body.angle = 0
	body.ground = false
	SoundDriver.play_sound(bounceSound)
