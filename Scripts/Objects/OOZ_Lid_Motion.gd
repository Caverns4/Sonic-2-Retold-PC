extends CharacterBody2D

var gravity = false
var spinning = false
var players = []

func _physics_process(delta: float) -> void:
	if gravity and !is_on_floor():
		velocity.y += (0.09375/GlobalFunctions.div_by_delta(delta))
	move_and_slide()
