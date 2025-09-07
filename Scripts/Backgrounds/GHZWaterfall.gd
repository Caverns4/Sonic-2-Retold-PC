@tool
extends Node2D

@export var maxHeight = 16
@export var animSpeed = 30.0

var frameTimer = 0.0

func _ready():
	if !animSpeed:
		animSpeed = 60.0
	
func _process(delta):
	var posBottom = maxHeight
	if !Engine.is_editor_hint():
		frameTimer += (delta * (animSpeed*2))
		if (posBottom+global_position.y) > Global.waterLevel:
			posBottom = Global.waterLevel - global_position.y

	if !Engine.is_editor_hint():
		#$WaterLength.region_rect = Rect2(0,frameTimer,32,posBottom)
		#$WaterTop.texture_offset.y = frameTimer#.offset.y = frameTimer
		$WaterTop.frame = wrap(round(frameTimer/6.0),0,3)
		$WaterLength.frame = wrap(round(frameTimer/6.0),0,3)
		$HpzWaterfallBottom.frame = wrap(round(frameTimer/6.0),0,3)

	$WaterLength.region_rect = Rect2(0,0,128,posBottom)
	$HpzWaterfallBottom.position.y = posBottom-8
	
