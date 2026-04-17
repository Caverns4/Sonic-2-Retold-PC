extends AnimatedSprite2D

var animFinished: bool = false

func _on_animation_finished() -> void:
	animFinished = true
	visible = false
	if (!$Explode.playing):
		queue_free()

func _on_Explode_finished() -> void:
	if (animFinished):
		queue_free()
