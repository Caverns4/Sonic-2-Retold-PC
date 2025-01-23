extends ParallaxBackground

func _process(delta):
	$ParallaxLayerD.motion_offset.x -= 8*delta
	$ParallaxLayerE.motion_offset.x -= 8*delta
	$ParallaxLayerF.motion_offset.x -= 12*delta
	$ParallaxLayerG.motion_offset.x -= 16*delta
	$ParallaxLayerH.motion_offset.x -= 24*delta
	$ParallaxLayerI.motion_offset.x -= 32*delta
	$ParallaxLayerJ.motion_offset.x -= 40*delta
	$ParallaxLayerK.motion_offset.x -= 48*delta
	$ParallaxLayerK2.motion_offset.x -= 56*delta
	$ParallaxLayerK3.motion_offset.x -= 64*delta
	$ParallaxLayerK4.motion_offset.x -= 80*delta
