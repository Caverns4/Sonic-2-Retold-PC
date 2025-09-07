extends ParallaxBackground


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$EarthLayer.motion_offset.x -= 64*delta
	$StarsF.motion_offset.x -= 32*delta
	$StarsE.motion_offset.x -= 64*delta
	$StarsD.motion_offset.x -= 96*delta
	$StarsC.motion_offset.x -= 128*delta
	$StarsB.motion_offset.x -= 160*delta
	$StarsA.motion_offset.x -= 256*delta
