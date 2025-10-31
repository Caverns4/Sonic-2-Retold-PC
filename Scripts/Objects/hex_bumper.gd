extends StaticBody2D

@export var power: float = 360
@export var move_distance: Vector2 = Vector2.ZERO

var home: Vector2 = global_position

func physics_collision(body, _hitVector):
	var col = body.objectCheck.get_collision_normal()
	if col:
		body.movement = (col.normalized()*power)
		$BumperSFX.play()
