extends EnemyProjectileBase

func _process(delta: float) -> void:
	if !$AnimationPlayer.is_playing():
		queue_free()
	super(delta)
