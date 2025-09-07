extends ParallaxBackground


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$ParallaxLayer.motion_offset.x -= delta*15
	$ParallaxLayer2.motion_offset.x -= delta*10
	$ParallaxLayer3.motion_offset.x -= delta*5
