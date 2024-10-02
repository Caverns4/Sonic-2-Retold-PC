extends StaticBody2D

var whichChar = 0 #The player this plaform will interact with, if one must be chosen.
var setUp = false

func _physics_process(delta: float) -> void:
	if whichChar > 0 and !setUp:
		for i in Global.players.size()+1:
			if (i-1) != whichChar-1:
				add_collision_exception_with(Global.players[i-1])
		setUp = true
