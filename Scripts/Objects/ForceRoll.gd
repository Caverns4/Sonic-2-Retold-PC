extends Area2D

var players = []
@export_enum("left", "right") var forceDirection = 1

func _physics_process(_delta):
	# if any players are found in the array, if they're on the ground make them roll
	if players.size() > 0:
		for i in players:
			if i.ground:
				if (i.movement*Vector2(1,0)).is_equal_approx(Vector2.ZERO):
					i.movement.x = 2*sign(-1+(forceDirection*2))*60.0
				if i.currentState != i.STATES.ROLL:
					i.set_state(i.STATES.ROLL)
					i.animator.play("roll")
					i.sfx[1].play()

func _on_ForceRoll_body_entered(body):
	body.forceRoll += 1
	body.forceDirection = forceDirection
	#if !players.has(body):
	#	players.append(body)


func _on_ForceRoll_body_exited(body):
	body.forceRoll -= 1
	#if players.has(body):
	#	players.erase(body)
