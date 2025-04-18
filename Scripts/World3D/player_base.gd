extends CharacterBody3D

@onready var sfx = $SFX.get_children()
@onready var sprite = $"Player Skin/Sonic2"
@onready var player_animator = AnimationPlayer

const TOP_SPEED = 10.0
const JUMP_VELOCITY = 7.0
const JUMP_KNUCKLES = 6.0

const INPUT_MEMORY_LENGTH = 20
const JUMP_BUFFER_TIME = 3.0/60.0 #Time after pressing jump button to buffer the input, in case it's pressed early.
# ================
# physics list order
# 0 Acceleration
# 1 Deceleration
# 2 Friction
# 3 Top Speed
# 4 Air Acceleration (No longer used, air accel is always Ground accel * 2)
# 5 Rolling Friction 
# 6 Rolling Deceleration
# 7 Gravity
# 8 Jump release velocity
var physicsList = [
# 0 Sonic (Primary Character physics)
[12/256.0, 0.50, 12/256.0,  6*60, 24/256.0, 12/256.0, 32/256.0, 56/256.0, 4],
# 1 Speed Shoes
[24/256.0, 0.50, 24/256.0, 12*60, 48/256.0, 12/256.0, 32/256.0, 56/256.0, 4],
# 2 Super Sonic
[32/256.0, 1.00, 12/256.0, 10*60, 64/256.0,  6/256.0, 32/256.0, 56/256.0, 4],
# 3 Super Forms besides Sonic
[24/256.0, 0.75, 12/256.0,  8*60, 48/256.0,  6/256.0, 32/256.0, 56/256.0, 4],
]
# ================
#Collision management
var floor_ray = RayCast3D.new()
var ray_length = 1.0  # Length for surface detection
var camera = Camera3D.new()

#Player parameters
var character = Global.CHARACTERS.SONIC
var playerSkins = [
	preload("res://Entitites3D/WorldTest/sonic_Player.tscn"),
	preload("res://Entitites3D/WorldTest/miles_Player.tscn"),
	# Knuckles
	# Amy
	# Mighty
	# Ray
]

#Current Ring count
var rings: int = 0
var ringChannel = 0

# Player inputs
enum INPUTS {XINPUT, YINPUT, ACTION, ACTION2, ACTION3, SUPER, PAUSE}
# Input control, 0 = 0ff, 1 = pressed, 2 = held
# (for held it's best to use inputs[INPUTS.ACTION] > 0)
# XInput and YInput are directions and are either -1, 0 or 1.
var inputs = [0,0,0,0,0,0,0,0]
const INPUTACTIONS_P1 = [["gm_left","gm_right"],["gm_up","gm_down"],"gm_action","gm_action2","gm_action3","gm_super","gm_pause"]
const INPUTACTIONS_P2 = [["gm_left_P2","gm_right_P2"],["gm_up_P2","gm_down_P2"],"gm_action_P2","gm_action2_P2","gm_action3_P2","gm_super_P2","gm_pause_P2"]
var inputActions = INPUTACTIONS_P1
# 0 = ai, 1 = player 1, 2 = player 2
var playerControl = 1
var inputMemory = []

# Movement
var inertia : float  = 0.0 # Movement Speed forward
var movement : Vector3 = Vector3.ZERO #linear motion
var last_movement_direction := Vector3.BACK
var xform : Transform3D
var jumpBuffer: float = 0

func _ready() -> void:
	Global.players.append(self)
	if Global.players[0] == self:
		character = Global.PlayerChar1
		inputActions = INPUTACTIONS_P1
		camera.global_position = $Node3D.global_position
		camera.look_at($"Player Skin".global_position)
		camera.current = true
		get_parent().call_deferred("add_child",(camera))
		if Global.PlayerChar2 > 0:
			var partner = self.duplicate()
			get_parent().add_child(partner)
			partner.name = "Partner"
			partner.global_position = global_position - Vector3(0,0,-2)
			get_parent().call_deferred("add_child", (partner))
			partner.camera = Global.players[0].camera
	else:
		character = Global.PlayerChar2
		playerControl = 2
		inputActions = INPUTACTIONS_P2
	
	#instantiate the player's skin
	var character = min(character,playerSkins.size())
	sprite.queue_free()
	var newSprite = playerSkins[character-1].instantiate()
	add_child(newSprite)
	sprite = newSprite
	
	for i in sprite.get_children(true):
		if i is AnimationPlayer:
			player_animator = i
	
	self.add_child(floor_ray)
	floor_ray.enabled = true
	floor_ray.target_position = Vector3.DOWN * ray_length

func _physics_process(delta: float) -> void:
	set_inputs()
	if !is_on_floor():
		movement.y += (-9.8 * delta)
	else:
		movement.y = 0.0
	
	if player_animator and is_on_floor():
		if (
			movement.length() >= (TOP_SPEED-1)):
			player_animator.play("Run")
		elif (movement.length() and movement.length() < (TOP_SPEED-1)):
			player_animator.play("Jog")
		else:
			player_animator.play("Idle")
			
	handle_input(delta)
	velocity = (global_basis * movement)
	move_and_slide()
	#look_at(movement,up_direction)
	rotate_to_floor_angle()
	# jump buffer time
	if jumpBuffer > 0.0:
		jumpBuffer -= delta
	
	if (Vector3(movement.x,0,movement.z).length() > 0.2):
		last_movement_direction = Vector3(movement.x,0,movement.z)
		var target_angle := Vector3.BACK.signed_angle_to(last_movement_direction,Vector3.UP)
		sprite.rotation.y = lerp_angle(sprite.rotation.y,target_angle,24*delta)
	
	
	if Global.players[0] == self:
		var adjusted_pos = (sprite.global_position + Vector3(0,1,0))
		camera.look_at(adjusted_pos)
		var camera_angle = (
			camera.global_position - adjusted_pos ).normalized() * 4
			
		if camera.global_position.distance_to(adjusted_pos) > 4:
			camera.global_position = camera_angle+adjusted_pos
	

func handle_input(delta):
	# Handle jump.
	if isActionPressed():
		jumpBuffer = JUMP_BUFFER_TIME

	# Todo: THis will need a total rewrite
	var input_axis = Vector2(
		inputs[INPUTS.XINPUT],inputs[INPUTS.YINPUT]).normalized()
	var forward = camera.global_basis.z
	var right = camera.global_basis.x

	if inertia < TOP_SPEED:
		if is_on_floor():
			inertia += (24*delta)
		else:
			inertia += (48*delta)
		#inertia = clampf(inertia,0-TOP_SPEED,TOP_SPEED)

	var move_direction = (forward * input_axis.y) + (right * input_axis.x)
	move_direction = move_direction.normalized()

	var movementParse = movement.move_toward(move_direction * inertia, 24.0*delta)
	movement = Vector3(movementParse.x,movement.y,movementParse.z)

	if jumpBuffer > 0 and is_on_floor():
		var jumpAngle = get_floor().normalized()
		if character != Global.CHARACTERS.KNUCKLES:
			movement += jumpAngle * JUMP_VELOCITY
			jumpBuffer = 0.0
		else:
			movement += jumpAngle * JUMP_KNUCKLES
			jumpBuffer = 0.0

		sfx[0].play()
		if player_animator:
			player_animator.play("Jump")

func hit_player(damagePosition: Vector3,ammount: int):
	if rings > 0:
		sfx[9].play
	rings = max(rings-abs(ammount),0)
	if inertia > 0.0:
		inertia = 0.0

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
	else:
		#Move back toward Zero
		xform = global_transform
		xform.basis.y = Vector3.UP
		xform.basis.x = -xform.basis.z.cross(Vector3.UP)
		xform.basis = xform.basis.orthonormalized()
		global_transform = xform
		up_direction = Vector3.UP.normalized()


func get_floor():
	# Check collision with the rays for floor, wall, and ceiling
	if floor_ray.is_colliding():
		#print(floor_ray.get_collision_normal())
		return floor_ray.get_collision_normal()
	return Vector3.ZERO

# Input buttons
func set_inputs():
	# verify that we're not an ai
	if (playerControl == 1):
		# input memory
		for _i in range(INPUT_MEMORY_LENGTH):
			inputMemory.append(inputs.duplicate(true))
	
	if playerControl > 0:
		inputs[INPUTS.ACTION] = (int(Input.is_action_pressed(inputActions[INPUTS.ACTION]))*2)-int(Input.is_action_just_pressed(inputActions[INPUTS.ACTION]))
		inputs[INPUTS.ACTION2] = (int(Input.is_action_pressed(inputActions[INPUTS.ACTION2]))*2)-int(Input.is_action_just_pressed(inputActions[INPUTS.ACTION2]))
		inputs[INPUTS.ACTION3] =  (int(Input.is_action_pressed(inputActions[INPUTS.ACTION3]))*2)-int(Input.is_action_just_pressed(inputActions[INPUTS.ACTION3]))
		inputs[INPUTS.SUPER] =  (int(Input.is_action_pressed(inputActions[INPUTS.SUPER]))*2)-int(Input.is_action_just_pressed(inputActions[INPUTS.SUPER]))
	
		inputs[INPUTS.XINPUT] = -int(Input.is_action_pressed(inputActions[INPUTS.XINPUT][0]))+int(Input.is_action_pressed(inputActions[INPUTS.XINPUT][1]))
		inputs[INPUTS.YINPUT] = -int(Input.is_action_pressed(inputActions[INPUTS.YINPUT][0]))+int(Input.is_action_pressed(inputActions[INPUTS.YINPUT][1]))

func isActionPressed():
	if inputs[INPUTS.ACTION] == 1:
		return true
	# For Spindash
	#if inputs[INPUTS.ACTION2] == 1:
	#	return true
	if inputs[INPUTS.ACTION3] == 1:
		return true
	return false

func isActionHeld():
	if inputs[INPUTS.ACTION]:
		return true
	# For Spindash
	#if inputs[INPUTS.ACTION2]:
	#	return true
	if inputs[INPUTS.ACTION3]:
		return true
	return false

func get_ring():
	rings += 1
	sfx[7+ringChannel].play()
	sfx[7].play()
	ringChannel = int(!ringChannel)
