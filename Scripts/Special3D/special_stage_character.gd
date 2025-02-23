extends CharacterBody3D

@onready var sfx = $SFX.get_children()

const SPEED = 6.0
const JUMP_VELOCITY = 6.5

#Current Ring count
var rings: int = 0
var ringChannel = 0

# Movement
var inertia = 0
var angle = 0

func _ready() -> void:
	Global.players.append(self)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if isActionPressed() and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_axis := Input.get_axis("gm_left","gm_right")
	var direction := (transform.basis * Vector3(input_axis, 0, 0)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = -SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = -SPEED

	move_and_slide()

func isActionPressed():
	if Input.is_action_just_pressed("gm_action"):
		return true
	if Input.is_action_just_pressed("gm_action2"):
		return true
	if Input.is_action_just_pressed("gm_action3"):
		return true
	return false

func get_ring():
	rings += 1
	sfx[7+ringChannel].play()
	sfx[7].play()
	ringChannel = int(!ringChannel)
