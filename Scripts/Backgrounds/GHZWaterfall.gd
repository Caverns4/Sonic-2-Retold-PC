@tool
extends Node2D

@export var maxHeight = 16

func _ready():
	pass
	
func _process(delta):
	var posBottom = maxHeight
	if !Engine.is_editor_hint():
		if (posBottom+global_position.y) > Global.waterLevel:
			posBottom = Global.waterLevel - global_position.y

	$WaterLength.size = Vector2(16,posBottom)
	$HpzWaterfallBottom.position.y = posBottom-8
	
