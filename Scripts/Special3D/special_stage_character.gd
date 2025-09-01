extends CharacterBody3D

@onready var sfx = $SFX.get_children()
@onready var sprite = $SsSonicTest
@onready var shadow_sprite = $CharacterShadow

const TOP_SPEED = 12.0
const JUMP_VELOCITY = 12.0
const JUMP_KNUCKLES = 10.0

const INPUT_MEMORY_LENGTH = 20
const JUMP_BUFFER_TIME = 3.0/60.0 #Time after pressing jump button to buffer the input, in case it's pressed early.

const UPRIGHT_TIME = 4

#Collision management
var floor_ray = RayCast3D.new()
var ray_length = 6.0  # Length for surface detection

#Player parameters
var character = Global.CHARACTERS.SONIC
var playerSkins = [
	preload("res://Graphics/Special Stage/SS_Sonic_Test.tscn"),
	preload("res://Graphics/Special Stage/SS_Tails.tscn"),
	preload("res://Graphics/Special Stage/SS_Knuckles.tscn"),
	preload("res://Graphics/Special Stage/SS_Amy.tscn"),
	preload("res://Graphics/Special Stage/SS_Mighty.tscn"),
	preload("res://Graphics/Special Stage/SS_Sonic_Test.tscn")
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
var target_up_dir: Vector3 = Vector3.UP
var jumpBuffer: float = 0
var dead: bool = false

func _ready() -> void:
	Global.special_stage_players.append(self)
	if Global.special_stage_players[0] == self:
		character = Global.PlayerChar1
		inputActions = INPUTACTIONS_P1
		$Camera3D.current = true
		if Global.PlayerChar2 > 0 and Global.two_player_mode:
			var partner = self.duplicate()
			get_parent().add_child(partner)
			partner.name = "Partner"
			partner.global_position = global_position - Vector3(0,0,-2)
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
	
	self.add_child(floor_ray)
	floor_ray.enabled = true
	floor_ray.target_position = Vector3.DOWN * ray_length

func _physics_process(delta: float) -> void:
	set_inputs()
	if !is_on_floor():
		movement.y += (-9.8 * 2 * delta)
	else:
		movement.y = 0.0
	
	if is_on_wall():
		inertia = -30.0 #Bounce back
		sfx[2].play()
	
	if sprite and is_on_floor():
		if inertia >= 10.0 and !sprite.animation == "run":
			sprite.play("run")
		elif inertia < 10.0 and !sprite.animation == "default":
			sprite.play("default")
	handle_input(delta)
	velocity = (global_basis * movement)
	move_and_slide()
	rotate_to_floor_angle(delta)
	# jump buffer time
	if jumpBuffer > 0.0:
		jumpBuffer -= delta
		
	if movement.y < -32.0 and !dead:
		Global.hud.SetupNextRound(true)
		dead = true

func handle_input(delta):
	# Handle jump.
	if isActionPressed():
		jumpBuffer = JUMP_BUFFER_TIME
	
	if jumpBuffer > 0 and is_on_floor():
		if character != Global.CHARACTERS.KNUCKLES:
			movement.y = JUMP_VELOCITY
			jumpBuffer = 0.0
		else:
			movement.y = JUMP_KNUCKLES
			jumpBuffer = 0.0
		
		sfx[0].play()
		if sprite:
			sprite.play("jump")

	# Only the left/right inputs are given to the player.
	# Forward and backward are controlled by the game.
	var input_axis = inputs[INPUTS.XINPUT]
	
	if inertia < TOP_SPEED:
		inertia += (12*delta)
	inertia = clampf(inertia,0-TOP_SPEED,TOP_SPEED)
	#print(inertia)
	
	movement = (Vector3(input_axis*8.0,movement.y,0-inertia))

func hit_player(damagePosition: Vector3,ammount: int):
	if rings > 0:
		sfx[9].play
	rings = max(rings-abs(ammount),0)
	if inertia > 0.0:
		inertia = 0.0

func rotate_to_floor_angle(delta):
	var surface_normal = get_floor().normalized()
	if surface_normal:
		target_up_dir = surface_normal
	up_direction = target_up_dir
	#Align to target angle
	var xform: Transform3D = global_transform
	xform.basis.y = xform.basis.y.move_toward(target_up_dir,UPRIGHT_TIME*delta)
	xform.basis.x = -xform.basis.z.cross(xform.basis.y)
	xform.basis = xform.basis.orthonormalized()
	global_transform = xform


func get_floor():
	# Check collision with the rays for floor, wall, and ceiling
	if floor_ray.is_colliding():
		#print(floor_ray.get_collision_normal())
		shadow_sprite.global_position = floor_ray.get_collision_point()
		var scale_factor: float = 1.0 - (
			global_position.distance_to(floor_ray.get_collision_point()) /5.0)
		scale_factor = clampf(scale_factor,0.0,1.0)
		shadow_sprite.scale = Vector3(scale_factor,1.0,scale_factor)
		
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
	if inputs[INPUTS.ACTION2] == 1:
		return true
	if inputs[INPUTS.ACTION3] == 1:
		return true
	return false



func get_ring():
	rings += 1
	sfx[7+ringChannel].play()
	sfx[7].play()
	ringChannel = int(!ringChannel)
