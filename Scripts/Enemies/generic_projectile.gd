extends EnemyProjectileBase

@export var gravity: bool = false

func _process(delta: float) -> void:
	if gravity:
		velocity.y += 400*delta
	super(delta)
