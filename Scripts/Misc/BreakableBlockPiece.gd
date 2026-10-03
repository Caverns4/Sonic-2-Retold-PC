extends Sprite2D

var gravity: float = 0.21875
var velocity: Vector2 = Vector2.ZERO
var lifeTime: float = 5.0

func _physics_process(delta: float) -> void:
	# increase gravity
	velocity.y += gravity/GlobalFunctions.div_by_delta(delta)
	translate(velocity*delta)
	# life time counter
	if lifeTime > 0:
		lifeTime -= delta
	else:
		queue_free()
