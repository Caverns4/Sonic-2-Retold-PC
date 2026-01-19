extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

enum STATES{NORMAL,AIR,HURT,LAUGH,FEAR}
var state: int = 0
var state_timer: float = 0.0

enum INPUTS {XINPUT, YINPUT, ACTION, ACTION2, ACTION3, SUPER, PAUSE}
# Input control, 0 = 0ff, 1 = pressed, 2 = held
# (for held it's best to use inputs[INPUTS.ACTION] > 0)
# XInput and YInput are directions and are either -1, 0 or 1.
var inputs: Array[float] = [0,0,0,0,0,0,0,0]
const INPUTACTIONS_P1 = [["gm_left","gm_right"],["gm_up","gm_down"],"gm_action","gm_action2","gm_action3","gm_super","gm_pause"]
var inputActions = INPUTACTIONS_P1

var controller: Node2D = null

const SPEED = 300.0
const JUMP_VELOCITY = -300.0



func _physics_process(delta: float) -> void:
	get_controls()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if inputs[INPUTS.ACTION] and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := inputs[INPUTS.XINPUT]
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, 120*delta)
		sprite.scale.x = sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED*2*delta)

	SetAnimation()
	move_and_slide()
	global_position.x = clampf(global_position.x,Global.hardBorderLeft,Global.hardBorderRight)


func get_controls():
	if controller:
		inputs[INPUTS.ACTION] = controller.input_abc
		inputs[INPUTS.XINPUT] = controller.input_x
		inputs[INPUTS.YINPUT] = controller.input_y
	else:
		inputs[INPUTS.ACTION] = (int(Input.is_action_pressed(inputActions[INPUTS.ACTION]))*2)-int(Input.is_action_just_pressed(inputActions[INPUTS.ACTION]))
		inputs[INPUTS.ACTION2] = (int(Input.is_action_pressed(inputActions[INPUTS.ACTION2]))*2)-int(Input.is_action_just_pressed(inputActions[INPUTS.ACTION2]))
		inputs[INPUTS.ACTION3] =  (int(Input.is_action_pressed(inputActions[INPUTS.ACTION3]))*2)-int(Input.is_action_just_pressed(inputActions[INPUTS.ACTION3]))
		inputs[INPUTS.XINPUT] = -int(Input.is_action_pressed(inputActions[INPUTS.XINPUT][0]))+int(Input.is_action_pressed(inputActions[INPUTS.XINPUT][1]))
		inputs[INPUTS.YINPUT] = -int(Input.is_action_pressed(inputActions[INPUTS.YINPUT][0]))+int(Input.is_action_pressed(inputActions[INPUTS.YINPUT][1]))


func SetAnimation():
	if velocity.y < 0:
		sprite.play("Jump")
	if is_on_floor():
		if velocity.x == 0:
			sprite.play("default")
		else:
			sprite.play("Walk")
