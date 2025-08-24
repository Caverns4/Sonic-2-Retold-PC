extends StaticBody2D


func physics_collision(body, hitVector):
	if hitVector.y > 0 and body.ground:
		body.angle = 0
