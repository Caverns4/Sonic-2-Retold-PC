extends AnimatableBody2D

# drop condition
func physics_collision(body, hitVector):
	if hitVector.y > 0 and body.ground:
		if get_parent().get("doDrop") != null:
			get_parent().doDrop = true
		# Elevators and HTZ lifts
		if get_parent().get("activated") != null:
			get_parent().activated = true
		# HTZ Lifts
		if get_parent().get("standees") != null:
			if !get_parent().standees.has(body):
				get_parent().standees.append(body)
