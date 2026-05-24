extends EnemyBase

const GRAVITY = 600

@export var idle_time: float = 1.0
@export var move_speed: float = 60
@export var shoot_time: float = 1.1
@export_enum("Left","Right")var direction: int = 0

@onready var sprite_node: Sprite2D = $Redz
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var floor_checker: RayCast2D = $Redz/FloorCheck
@onready var state_time: Timer = $Timers/StateTime
@onready var bulletPoint: Node2D = $Redz/BulletPoint
@onready var fire_weaver: Timer = $Timers/FireWeave

var Projectile: PackedScene = preload("res://Entities/Enemies/Projectiles/RedzFire.tscn")
var bullet: Node2D = null
var bulletSound: AudioStream = preload("res://Audio/SFX/Objects/s2br_Flamethrower.wav")

enum STATES{WALK,IDLE,SHOOT}

var state: STATES = STATES.WALK
var shootTimer: float = 0.0

var targets: Array[Player2D] = []

func _ready() -> void:
	direction = (direction*2)-1
	super()
	_change_direction(move_speed)
	state_time.connect("timeout",_on_idle_time_timeout)

func _physics_process(delta: float) -> void:
	match state:
		STATES.WALK:
			EdgeCheck()
		STATES.IDLE:
			pass
		STATES.SHOOT:
			if !animator.is_playing():
				state = STATES.IDLE
				animator.play("RESET")
				state_time.start(idle_time/2)
			else:
				shootBullet(delta)
	if !is_on_floor():
		velocity.y += (GRAVITY*delta)
	move_and_slide()

func EdgeCheck() -> void:
	if (is_on_wall() or !floor_checker.is_colliding()):
		velocity.x = 0.0
		if targets:
			state = STATES.SHOOT
			animator.play("SHOOT")
			fire_weaver.start(shoot_time)
		else:
			state = STATES.IDLE
			animator.play("RESET")
			state_time.start(idle_time)

func _change_direction(speed: float) -> void:
	direction = -direction
	sprite_node.scale.x = 0-sign(direction)
	floor_checker.force_raycast_update()
	velocity.x = speed*direction
	state = STATES.WALK
	animator.play("WALK")

func shootBullet(delta: float) -> void:
	shootTimer+=delta
	if shootTimer >= 0.05:
		shootTimer = 0.0
		#Shoot a fireball
		SoundDriver.play_sound2(bulletSound)
		bullet = Projectile.instantiate()
		get_parent().add_child(bullet)
		# set position with offset
		bullet.global_position = bulletPoint.global_position
		bullet.scale.x = 1
		bullet.velocity.x = (direction * 120)
		bullet.velocity.y = (fire_weaver.time_left*80) - 28

func _on_player_check_body_entered(body: Node2D) -> void:
	targets.append(body)


func _on_player_check_body_exited(body: Node2D) -> void:
	targets.erase(body)

func _on_idle_time_timeout() -> void:
	if state == STATES.IDLE:
		_change_direction(move_speed)
