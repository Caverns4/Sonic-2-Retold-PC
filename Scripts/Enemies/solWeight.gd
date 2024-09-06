extends CharacterBody2D

@export var pivotCenter = int(-32)

const GRAVITY = 800
const ACCEL = 6

var origin = Vector2.ZERO
var direction = 1*sign(pivotCenter)
var lobForce = 0
var ground = false
#var movement = Vector2.ZERO #Used to emulat Physics object

func _ready():
	direction = 1*sign(pivotCenter)
	origin.y = global_position.y
	origin.x = global_position.x + pivotCenter

func _physics_process(delta):
	if lobForce < 0:
		lobForce -= ACCEL
		velocity.x = lobForce
	if lobForce > 0:
		lobForce += ACCEL
		velocity.x = lobForce
		
	if lobForce > -0.1 and lobForce < 0.1:
		lobForce = 0.0
		velocity.x = 0.0
	
	MoveWithGravity(delta)
	if !is_on_floor():
		ClampXCoords()

func ClampXCoords():
	var leftBound = origin.x
	var rightBound = origin.x
	rightBound += abs(pivotCenter)
	leftBound -= abs(pivotCenter)
	global_position.x = clampf(global_position.x,leftBound,rightBound)

func MoveWithGravity(delta):
	# Velocity movement
	set_velocity(velocity)
	# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `Vector2.DOWN`
	set_up_direction(Vector2.UP)
	move_and_slide()
	ground = is_on_floor()
	# Gravity
	if !is_on_floor():
		velocity.y += GRAVITY*delta
	if is_on_floor() and lobForce != 0:
		velocity = Vector2.ZERO
		lobForce = 0