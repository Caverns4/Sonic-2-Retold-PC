@tool
extends Node2D

@export var maxHeight = 16

func _ready():
	pass
	
func _process(delta):
	$WaterLength.size = Vector2(16,maxHeight)
	$HpzWaterfallBottom.position.y = maxHeight-8
