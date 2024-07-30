extends CharacterBody2D

func _physics_process(delta):
	if is_on_floor():
		velocity.y = 0
