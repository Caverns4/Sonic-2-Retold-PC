class_name WindTunnelBreakablePiece
extends CharacterBody2D

@export var launch_speed: Vector2 = Vector2.ZERO

var nailed_down: bool = true :
	set(value):
		nailed_down = value
		if value:
			$AnimatedSprite2D.play("default")
		else:
			$AnimatedSprite2D.play("broken")

func _physics_process(delta: float) -> void:
	if !nailed_down:
		if !is_on_floor(): velocity += get_gravity() * delta
		velocity.x = move_toward(velocity.x, 0, delta)
		move_and_slide()
	
	if global_position.y > Global.hardBorderBottom:
		queue_free()

func launch_in_direction(direction: int) -> void:
	velocity = launch_speed
	velocity.x *= direction
	nailed_down = false
