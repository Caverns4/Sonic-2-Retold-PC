extends CharacterBody2D

@export var pivotCenter = int(-32)

const GRAVITY = 600

var direction = 1*sign(pivotCenter)
var ground = false

func _ready():
	var direction = 1*sign(pivotCenter)

func _physics_process(delta):
	ground = is_on_floor()
	MoveWithGravity(delta)

func MoveWithGravity(delta):
	# Velocity movement
	set_velocity(velocity)
	# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `Vector2.DOWN`
	set_up_direction(Vector2.UP)
	move_and_slide()
	# Gravity
	if !is_on_floor():
		velocity.y += GRAVITY*delta
