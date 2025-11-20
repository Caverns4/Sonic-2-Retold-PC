extends StaticBody2D

var sfx = preload("res://Audio/SFX/Objects/CNZ_Bonus.wav")

var state = 0

func physics_collision(body, hitVector):
	if abs(hitVector.y) >= 1.0:
		var testpos: float = body.global_position.y-global_position.y
		body.movement.y = max(abs(body.movement.y),360) * sign(testpos)
	else:
		body.movement = hitVector.rotated(deg_to_rad(180)) * 360
	SoundDriver.play_sound(sfx)
	Global.add_score(global_position,0,Global.players.find(body))
	state +=1
	$Sprite2D.frame = state
	if state > 2:
		queue_free()
