class_name CutsceneEggman
extends CharacterBody2D

## A cutscene handler node that will send input to Eggman.
@export var controller: Node = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

enum STATES{NORMAL,AIR,HURT,LAUGH,FEAR}
var state: STATES = STATES.NORMAL
var state_timer: float = 0.0

enum INPUTS {XINPUT, YINPUT, ACTION, ACTION2, ACTION3, SUPER, PAUSE}
# Input control, 0 = 0ff, 1 = pressed, 2 = held
# (for held it's best to use inputs[INPUTS.ACTION] > 0)
# XInput and YInput are directions and are either -1, 0 or 1.
var inputs: Array[float] = [0,0,0,0,0,0,0,0]
const INPUTACTIONS_P1 = [["ui_left","ui_right"],["ui_up","ui_down"],"ui_accept","ui_select","ui_cancel","ui_super","ui_pause"]
var inputActions: Array = INPUTACTIONS_P1

const SPEED = 300.0
const JUMP_VELOCITY = -300.0

var target_animation: String = "default"

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
	move_and_slide()
	animate_eggman()
	global_position.x = clampf(global_position.x,Global.hardBorderLeft,Global.hardBorderRight)

func set_facing_direction(left: bool = false) -> void:
	sprite.scale.x = -1.0 if left else 1.0

func get_controls() -> void:
	if !controller:
		inputs[INPUTS.ACTION] = (int(Input.is_action_pressed(inputActions[INPUTS.ACTION]))*2)-int(Input.is_action_just_pressed(inputActions[INPUTS.ACTION]))
		inputs[INPUTS.ACTION2] = (int(Input.is_action_pressed(inputActions[INPUTS.ACTION2]))*2)-int(Input.is_action_just_pressed(inputActions[INPUTS.ACTION2]))
		inputs[INPUTS.ACTION3] =  (int(Input.is_action_pressed(inputActions[INPUTS.ACTION3]))*2)-int(Input.is_action_just_pressed(inputActions[INPUTS.ACTION3]))
		inputs[INPUTS.XINPUT] = -int(Input.is_action_pressed(inputActions[INPUTS.XINPUT][0]))+int(Input.is_action_pressed(inputActions[INPUTS.XINPUT][1]))
		inputs[INPUTS.YINPUT] = -int(Input.is_action_pressed(inputActions[INPUTS.YINPUT][0]))+int(Input.is_action_pressed(inputActions[INPUTS.YINPUT][1]))


func animate_eggman() -> void:
	if velocity.y < 0:
		sprite.play("Jump")
	if is_on_floor():
		if velocity.x == 0:
			sprite.play(target_animation)
		else:
			sprite.play("Walk")
