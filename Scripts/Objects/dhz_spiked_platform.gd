extends AnimatableBody2D


# Collision check (this is where the player gets hurt, OW!)
func physics_collision(body, hitVector):
	if abs(hitVector.x) > 0.5:
		body.hit_player(global_position,0,4)
