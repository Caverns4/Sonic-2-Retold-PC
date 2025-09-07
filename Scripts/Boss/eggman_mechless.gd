extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

enum STATES{NORMAL,AIR,HURT,LAUGH,FEAR}
var state: int = 0
var state_timer: float = 0.0

const SPEED = 240.0
const JUMP_VELOCITY = -300.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("gm_action2") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED*delta)
		sprite.scale.x = sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED*2*delta)

	SetAnimation()
	move_and_slide()
	# just for fun
	var limiter = Global.players[0]
	global_position.x = clampf(global_position.x,limiter.limitLeft,limiter.limitRight)


func SetAnimation():
	if velocity.y < 0:
		sprite.play("Jump")
	if is_on_floor():
		if velocity.x == 0:
			sprite.play("default")
		else:
			sprite.play("Walk")
