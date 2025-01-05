extends StaticBody2D

var whichChar = null #The player this plaform will interact with, if one must be chosen.
var setUp = false

var active = false
var activeTimer = 0.1

func _physics_process(delta: float) -> void:
	if active:
		activeTimer -= delta
		if activeTimer <= 0 and active:
			active = false

	if whichChar and !setUp:
		for player in Global.players:
			if player != whichChar:
				add_collision_exception_with(player)
			setUp = true

# physics collision check, see physics object
func physics_collision(body, hitVector):
	active = true
	activeTimer = 0.1
