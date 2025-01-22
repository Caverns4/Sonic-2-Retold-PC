extends ParallaxBackground

func _process(delta):
	$ParallaxLayerD.motion_offset.x -= 4*delta
	$ParallaxLayerE.motion_offset.x -= 6*delta
	$ParallaxLayerF.motion_offset.x -= 8*delta
	$ParallaxLayerG.motion_offset.x -= 10*delta
	$ParallaxLayerH.motion_offset.x -= 14*delta
	$ParallaxLayerI.motion_offset.x -= 18*delta
	$ParallaxLayerJ.motion_offset.x -= 22*delta
	$ParallaxLayerK.motion_offset.x -= 32*delta
	$ParallaxLayerK2.motion_offset.x -= 48*delta
	$ParallaxLayerK3.motion_offset.x -= 64*delta
