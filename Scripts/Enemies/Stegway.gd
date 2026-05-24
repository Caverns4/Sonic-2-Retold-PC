extends EnemyBase

const GRAVITY = 600
const DASH_CHARGE_TIME = 0.5 #Time to rev before charaging a player

@export var idle_time: float = 1.0
@export var move_speed: float = 60
@export var revSound: AudioStream = preload("res://Audio/SFX/Player/s2br_SpindashRev.wav")
@export_enum("Left","Right")var direction: int = 0

@onready var sprite_node: Sprite2D = $Stegway
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var floor_checker: RayCast2D = $Stegway/FloorCheck
@onready var state_time: Timer = $Timers/StateTime
@onready var flame_effect: AnimatedSprite2D = $Stegway/BuzzerFlame

enum STATES{WALK,IDLE,CHARGE,DASH}
var state: STATES = STATES.WALK
var targets: Array[Player2D] = []

func _ready() -> void:
	flame_effect.hide()
	direction = (direction*2)-1
	super()
	_change_direction(move_speed)
	state_time.connect("timeout",_on_idle_time_timeout)

func _physics_process(delta: float) -> void:
	match state:
		STATES.WALK:
			if targets: _charge_dash()
			EdgeCheck()
		STATES.DASH:
			EdgeCheck()
	if !is_on_floor():
		velocity.y += (GRAVITY*delta)
	move_and_slide()

func EdgeCheck() -> void:
	if (is_on_wall() or !floor_checker.is_colliding()):
		velocity.x = 0.0
		state = STATES.IDLE
		animator.play("RESET")
		state_time.start(idle_time)
		flame_effect.hide()

func _change_direction(speed: float) -> void:
	direction = -direction
	sprite_node.scale.x = 0-sign(direction)
	floor_checker.force_raycast_update()
	velocity.x = speed*direction
	state = STATES.WALK
	animator.play("WALK")

func _charge_dash() -> void:
	var wait_time:float = DASH_CHARGE_TIME
	for i:Player2D in targets:
		if (i.super_time > 0):
			direction = sign(global_position.x - i.global_position.x)
			sprite_node.scale.x = abs(sprite_node.scale.x)*-direction
			wait_time = wait_time/2
	state_time.start(wait_time)
	state = STATES.CHARGE
	animator.play("CHARGE")
	velocity.x = 0
	SoundDriver.play_sound(revSound)


func _on_player_check_body_entered(body: Node2D) -> void:
	targets.append(body)


func _on_player_check_body_exited(body: Node2D) -> void:
	targets.erase(body)


func _on_idle_time_timeout() -> void:
	if state == STATES.IDLE:
		_change_direction(move_speed)
	if state == STATES.CHARGE:
		sprite_node.scale.x = abs(sprite_node.scale.x)*-direction
		state = STATES.DASH
		animator.play("DASH")
		velocity.x = direction*move_speed*4
		flame_effect.show()
