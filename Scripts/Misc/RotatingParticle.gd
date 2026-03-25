extends AnimatedSprite2D
var time: float = 0
var direction: int = 1
var velocity: Vector2 = Vector2.ZERO
var getTarget: Node2D = null


func _process(delta: float) -> void:
	# rotate
	position = position.rotated(deg_to_rad(360*delta)*direction)
	if getTarget != null:
		get_parent().global_position.move_toward(getTarget.global_position,delta)
	#translate(velocity*0.5*delta)
	time += delta
	if time > 0.3:
		queue_free()
