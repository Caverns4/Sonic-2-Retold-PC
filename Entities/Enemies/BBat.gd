extends EnemyBase
# Todo

var hoverOffset = 0.0

func _process(delta):
	super(delta)

func _physics_process(delta):
	updateHoveringPos(delta)
	pass

func updateHoveringPos(delta):
	# change the hover offset
	global_position.y = global_position.y-hoverOffset
	hoverOffset = move_toward(hoverOffset,cos(Global.levelTime*4)*4,delta*10)
	global_position.y = global_position.y+hoverOffset
