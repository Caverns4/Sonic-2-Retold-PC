extends AnimatableBody2D

# drop condition
func physics_collision(_body: CharacterBody2D, hitVector: Vector2) -> void:
	get_parent()._do_tilt(hitVector.x)
