extends CharacterBody3D

@onready var sfx = $SFX.get_children()

const TOP_SPEED = 6.0
const JUMP_VELOCITY = 6.5

#Collision management
var floor_ray = RayCast3D.new()
var ray_length = 2.0  # Length for surface detection

#Current Ring count
var rings: int = 0
var ringChannel = 0

# Movement
var xform : Transform3D
# Input movement ignoring rotations.
var inertia : Vector2 = Vector2.ZERO # Lateral motion
var localMovement = Vector3.ZERO #The above, plus jumping movement.
# Base movement. This is likely going to be 0 most of the time.
var movement = Vector3.ZERO

func _ready() -> void:
	Global.players.append(self)
	self.add_child(floor_ray)
	floor_ray.enabled = true
	floor_ray.target_position = Vector3.DOWN * ray_length

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += up_direction * -9.8 * delta
	#if !is_on_floor():
	#	localMovement.y += 9.8 * delta
	var direction = Vector3.ZERO
	direction = handle_input(delta)
	move_and_slide()
	velocity -= direction * TOP_SPEED
	
	rotate_to_floor_angle()

func handle_input(delta):
	# Handle jump.
	if isActionPressed() and is_on_floor():
		localMovement = up_direction * (0-JUMP_VELOCITY)

	# Only the left/right inputs are given to the player.
	# Forward and backward are controlled by the game.
	var input_axis := Input.get_axis("gm_left","gm_right")
	
	var direction = (global_basis * Vector3(input_axis,0,0)).normalized()
	direction += (global_basis * Vector3(0,0,-1))
	velocity += direction * TOP_SPEED
	
	return direction

func rotate_to_floor_angle():
	var surface_normal = get_floor()
	if surface_normal:
		#Align to nearest floor
		xform = global_transform
		xform.basis.y = surface_normal
		xform.basis.x = -xform.basis.z.cross(surface_normal)
		xform.basis = xform.basis.orthonormalized()
		global_transform = xform
		
		up_direction = surface_normal.normalized()


func get_floor():
	# Check collision with the rays for floor, wall, and ceiling
	if floor_ray.is_colliding():
		#print(floor_ray.get_collision_normal())
		return floor_ray.get_collision_normal()
	return Vector3.ZERO

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
