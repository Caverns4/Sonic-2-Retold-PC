extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.waterLevel:
		if global_position.y > Global.waterLevel:
			$PointLight2D.enabled = false
		else:
			$PointLight2D.enabled = true
