extends Sprite2D

var hoverOffset = 0
var timer = 0.0

func _physics_process(delta: float) -> void:
	timer += delta
	updateHoveringPos(delta)

func updateHoveringPos(delta):
	# change the hover offset
	global_position.y = global_position.y-hoverOffset
	hoverOffset = move_toward(hoverOffset,cos(timer*4)*8,delta*10)
	global_position.y = global_position.y+hoverOffset
