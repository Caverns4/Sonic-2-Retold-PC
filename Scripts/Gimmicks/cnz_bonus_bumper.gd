extends StaticBody2D

var sfx: AudioStream = preload("res://Audio/SFX/Objects/CNZ_Bonus.wav")

var state: int = 0

func physics_collision(body: Player2D, hitVector: Vector2) -> void:
	if abs(hitVector.y) >= 1.0:
		var testpos: float = body.global_position.y-global_position.y
		body.movement.y = max(abs(body.movement.y),360) * sign(testpos)
	else:
		body.movement = hitVector.rotated(deg_to_rad(180)) * 360
	SoundDriver.play_sound(sfx)
	Global.add_score(global_position,0,Global.players.find(body))
	state +=1
	$Sprite2D.frame = wrapi(state,0,3)
	if state > 2:
		queue_free()
