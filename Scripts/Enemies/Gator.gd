extends EnemyBase


@export_enum("Left","Right")var direction: int = 0
enum STATES{WALK,IDLE}
var state: int = STATES.WALK
var state_timer: float = 0.0

var players = []

const SPEED = 60.0

func _ready() -> void:
	direction = (direction*2)-1
	defaultMovement = false
	super()
	setDirection()

func _physics_process(delta: float) -> void:
	state_timer -= delta
	if state_timer <= 0.0 and state == STATES.IDLE:
		state = STATES.WALK
		direction = 0-direction
		setDirection()
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	$RayCast2D.force_raycast_update()
	if state == STATES.WALK and (!$RayCast2D.is_colliding() or is_on_wall()):
		state = STATES.IDLE
		velocity.x = 0.0
		state_timer = 1.0

	#Update the animation
	$GatorSprite.frame = 0
	var _prox = GlobalFunctions.get_orientation_to_player(global_position)
	if _prox.x < 96 and sign(_prox.x) == sign(direction) and abs(_prox.y) < 64:
		$GatorSprite.frame = 3
	if velocity.x != 0:
		$GatorSprite.frame += wrapi(Global.globalTimer*8,0,3)
	$GatorSprite/Area2D.monitoring = ($GatorSprite.frame >= 3)
	move_and_slide()

func setDirection():
	velocity.x = direction * SPEED
	$GatorSprite.scale.x = 0-sign(direction)
	$RayCast2D.position.x = abs($RayCast2D.position.x) * sign(velocity.x)
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.hit_player()
	pass
	#players.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	pass
	#players.erase(body)
