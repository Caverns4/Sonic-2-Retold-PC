extends ParallaxBackground

var xScrollMinAmount = 0.25
var xScrollMaxAmount = 2

@export var cloudLayers = [Node2D] #Number of nodes
var cloudSpeeds = [0] #the speed each cloud layer should move at, auto-generated

func _ready():
	pass

func _process(delta):
	$ParallaxLayerD.motion_offset.x -= 0.125
	$ParallaxLayerE.motion_offset.x -= 0.25
	$ParallaxLayerF.motion_offset.x -= 0.375
	$ParallaxLayerG.motion_offset.x -= 0.5
	$ParallaxLayerH.motion_offset.x -= 0.625
	$ParallaxLayerI.motion_offset.x -= 0.875
	$ParallaxLayerJ.motion_offset.x -= 1
	$ParallaxLayerK.motion_offset.x -= 1.125
	$ParallaxLayerK2.motion_offset.x -= 1.25
	$ParallaxLayerK3.motion_offset.x -= 1.375
	#if enabled:
	#	for i in cloudLayers.size:
	#		var this = get_node(cloudLayers[i])
	#		this.motion_offset.x(
	#		this.motion_offset.x + cloudSpeeds[i],
	#		0)
	pass
