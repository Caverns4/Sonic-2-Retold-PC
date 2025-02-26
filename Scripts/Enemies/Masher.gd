extends EnemyBase

var jumpHeight = 5

# Original Code RefCounted translated by VAdaPEGA
var animFrame = 0.0

func _ready():
	# initial velocity
	velocity.y = -4
	set_physics_process(false)
	set_process(false)
	

func _physics_process(delta):
	# gravity
	position.y = min(position.y,0)
	velocity.y += (0.09375/GlobalFunctions.div_by_delta(delta))
	
	# reset velocity
	if position.y >= 0:
		velocity.y = 0-abs(jumpHeight)*60
	

func _process(delta):
	super(delta)
	# animation states
	if velocity.y > 0:
		# stationary
		animFrame += (60.0/8.0)*delta
	else:
		# slow animation
		animFrame += (60.0/4.0)*delta
	
	animFrame = fmod(animFrame,($Masher.hframes*$Masher.vframes))
	$Masher.frame = floor(animFrame)


func _on_VisibilityEnabler2D_screen_entered():
	set_physics_process(true)
	set_process(true)


func _on_VisibilityEnabler2D_screen_exited():
	set_physics_process(false)
	set_process(false)
