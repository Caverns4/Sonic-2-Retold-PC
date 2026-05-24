extends EnemyBase

const GRAVITY = 600

@export_enum("Left","Right")var direction: int = 0
@export var idle_time: float = 1.0
@export var move_speed: float = 60

@onready var sprite_node: Sprite2D = $Gator
@onready var floor_checker: RayCast2D = $Gator/FloorCheck
@onready var state_time: Timer = $Timers/StateTime
@onready var mouth_hurtbox: Area2D = $Gator/MouthHurtbox


enum STATES{WALK,IDLE}
var state: int = STATES.WALK
var state_timer: float = 0.0

func _ready() -> void:
	direction = (direction*2)-1
	super()
	_change_direction(move_speed)
	state_time.connect("timeout",_on_idle_time_timeout)

func _physics_process(delta: float) -> void:
	match state:
		STATES.WALK:
			EdgeCheck()
	if !is_on_floor():
		velocity.y += (GRAVITY*delta)
	move_and_slide()
	update_animation()

func EdgeCheck() -> void:
	if (is_on_wall() or !floor_checker.is_colliding()):
		velocity.x = 0.0
		state = STATES.IDLE
		state_time.start(idle_time)

func update_animation() -> void:
	sprite_node.frame = 0
	var _prox: Vector2 = GlobalFunctions.get_orientation_to_player(global_position)
	if _prox.x < 96 and sign(_prox.x) == sign(direction) and abs(_prox.y) < 64:
		sprite_node.frame = 3
	if velocity.x != 0:
		sprite_node.frame += wrapi(int(Global.globalTimer*8),0,3)
	mouth_hurtbox.monitoring = (sprite_node.frame >= 3)

func _change_direction(speed: float) -> void:
	direction = -direction
	sprite_node.scale.x = 0-sign(direction)
	floor_checker.force_raycast_update()
	velocity.x = speed*direction
	state = STATES.WALK

func _on_mouth_hurtbox_body_entered(body: Node2D) -> void:
	if body is Player2D:
		body.hit_player()

func _on_idle_time_timeout() -> void:
	if state == STATES.IDLE:
		_change_direction(move_speed)
