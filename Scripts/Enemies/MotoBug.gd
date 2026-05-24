extends EnemyBase

const GRAVITY = 600

@export var idle_time: float = 1.0
@export var move_speed: float = 30
@export_enum("Left","Right")var direction: int = 0

@onready var sprite_node: Sprite2D = $Motobug
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var floor_checker: RayCast2D = $Motobug/FloorCheck
@onready var state_time: Timer = $Timers/StateTime
@onready var flame_effect: AnimatedSprite2D = $Motobug/BuzzerFlame

enum STATES{WALK,IDLE,DASH}
var state: STATES = STATES.WALK

var targets: Array[Player2D] = [] #Player objects, if any are detected.
var Particle: PackedScene = preload("res://Entities/Misc/GenericParticle.tscn")

func _ready() -> void:
	flame_effect.hide()
	direction = (direction*2)-1
	super()
	_change_direction(move_speed)
	state_time.connect("timeout",_on_idle_time_timeout)

func _physics_process(delta: float) -> void:
	match state:
		STATES.DASH:
			EdgeCheck()
		STATES.WALK:
			if targets:
				velocity.x = direction*move_speed*4
				flame_effect.visible = true
				state = STATES.DASH
			# Edge check
			EdgeCheck()
	if !is_on_floor():
		velocity.y += (GRAVITY*delta)
	move_and_slide()

func EdgeCheck() -> void:
	if (is_on_wall() or !floor_checker.is_colliding()):
		velocity.x = 0.0
		state_time.start(idle_time)
		state = STATES.IDLE
		animator.play("RESET")
		flame_effect.visible = false

func _change_direction(speed: float) -> void:
	direction = -direction
	sprite_node.scale.x = 0-sign(direction)
	floor_checker.force_raycast_update()
	velocity.x = speed*direction
	state = STATES.WALK
	animator.play("WALK")

func _on_player_check_body_entered(body: Node2D) -> void:
	targets.append(body)

func _on_player_check_body_exited(body: Node2D) -> void:
	targets.erase(body)

func _on_idle_time_timeout() -> void:
	_change_direction(move_speed)


func _on_smoke_emit_timeout() -> void:
	if velocity.x != 0.0:
		var part: Node2D = Particle.instantiate()
		get_parent().add_child(part)
		part.global_position = global_position-(Vector2(20,0)*direction)
		part.play("MotoBugSmoke")
