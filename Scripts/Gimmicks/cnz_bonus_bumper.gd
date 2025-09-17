extends StaticBody2D

var sfx = preload("res://Audio/SFX/Objects/CNZ_Bonus.wav")

var state = 0

func physics_collision(body, hitVector):
	body.movement = hitVector.rotated(180) * 360
	SoundDriver.play_sound(sfx)
	state +=1
	$Sprite2D.frame = state
	if state > 2:
		queue_free()
