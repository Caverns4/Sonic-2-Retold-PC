extends Node2D

func _ready() -> void:
	if Global.saved_checkpoint >= 0:
		queue_free()
