extends EnemyBase
# Todo

var hoverOffset = 0.0

enum STATES{IDLE,DIVE,COOLDOWN}
var state = STATES.IDLE

func _process(delta):
	super(delta)

func _physics_process(delta):
	match state:
		STATES.IDLE:
			updateHoveringPos(delta)
	pass

func updateHoveringPos(delta):
	# change the hover offset
	global_position.y = global_position.y-hoverOffset
	hoverOffset = move_toward(hoverOffset,cos(Global.levelTime*4)*4,delta*10)
	global_position.y = global_position.y+hoverOffset
