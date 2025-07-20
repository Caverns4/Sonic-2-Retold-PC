extends EnemyBase

@export var chain_length = 8
@export var move_speed = 30
@export var walk_time = 1.0
@onready var _claw:Node2D = $ClawAttack
@onready var _animation:AnimationPlayer = $AnimationPlayer

enum  STATE{WALK,WAIT,JAB}
var state: int = 0
var state_time: float = 1.0
var move_dir: int = -1

func _ready() -> void:
	_claw.chain_length = chain_length
	velocity.x = 30*move_dir
	defaultMovement = false
	super()

func _physics_process(delta: float) -> void:
	match state:
		STATE.WALK:
			state_time -= delta
			if state_time <= 0.0:
				state = STATE.WAIT
				state_time = 1.0
				velocity.x = 0
		STATE.WAIT:
			state_time -= delta
			if state_time <= 0.0:
				state = STATE.WALK
				state_time = walk_time
				move_dir = 0-move_dir
				velocity.x = move_speed*move_dir
		
		
	
	if !is_on_floor():
		velocity.y += 9.8*delta
	move_and_slide()
	if is_on_wall() and state == 0:
		move_dir = 0-move_dir
		velocity.x = move_speed*move_dir
	
	if velocity.x != 0:
		_animation.play("Walk")
	else:
		_animation.play("RESET")
