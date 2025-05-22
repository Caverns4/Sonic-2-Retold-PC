extends EnemyBase

const SPEED = 180.0
const MAX_JUMP_VELOCITY = 360.0

func _ready() -> void:
	$VisibleOnScreenEnabler2D.visible = true
	defaultMovement = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		var direction: int = Global.players[0].global_position.x - global_position.x
		
		velocity.y = clamp(
			0-abs(direction)*5,
			0-MAX_JUMP_VELOCITY,
			-120)
		
		direction = clampi(direction,-1,1)
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
