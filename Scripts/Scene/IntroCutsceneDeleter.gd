extends Node2D

func _ready() -> void:
	if Global.saved_checkpoint >= 0 or !visible:
		queue_free()
