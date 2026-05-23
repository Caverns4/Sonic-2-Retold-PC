extends AnimatableBody2D

# drop condition
func physics_collision(body: CharacterBody2D, hitVector: Vector2) -> void:
	if hitVector.y > 0:
		get_parent()._do_tilt(body.position.x)

func set_collision_disable(state: bool) -> void:
	$CollisionShape2D.disabled = state
