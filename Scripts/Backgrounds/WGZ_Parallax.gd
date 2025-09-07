extends ParallaxBackground

func _physics_process(delta: float) -> void:
	$Clouds1.motion_offset.x -= 64*delta
	$Clouds2.motion_offset.x -= 32*delta
	$Clouds3.motion_offset.x -= 16*delta
