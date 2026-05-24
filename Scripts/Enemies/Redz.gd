extends EnemyBase

const GRAVITY = 600

@export var idle_time: float = 1.0
@export var move_speed: float = 60
@export var shoot_time: float = 1.1

var Projectile: PackedScene = preload("res://Entities/Enemies/Projectiles/RedzFire.tscn")
var bullet: Node2D = null
var bulletSound: AudioStream = preload("res://Audio/SFX/Objects/s2br_Flamethrower.wav")

enum STATES{WALK,IDLE,SHOOT}

var state: STATES = STATES.WALK
var direction: int = 1
var shootTimer: float = 0.0

var targets: Array[Player2D] = []

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var bulletPoint: Node2D = $Redz/BulletPoint
@onready var floor_checker: RayCast2D = $Redz/FloorCheck
@onready var state_time: Timer = $Timers/IdleTime
@onready var fire_weaver: Timer = $Timers/FireWeave

func _ready() -> void:
	defaultMovement = false
	$VisibleOnScreenEnabler2D.visible = true
	animator.play("WALK")
	global_scale = Vector2(1,1)
	super()
	

func _physics_process(delta: float) -> void:
	match state:
		STATES.WALK:
			# Edge check
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
	#floor_checker.force_raycast_update()
	if (is_on_wall() or !floor_checker.is_colliding()):
		velocity.x = 0
		if targets:
			state = STATES.SHOOT
			animator.play("SHOOT")
			fire_weaver.start(shoot_time)
		else:
			state = STATES.IDLE
			animator.play("RESET")
			state_time.start(idle_time)

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
		direction = -direction
		$Redz.scale.x = abs($Redz.scale.x)*-direction
		state = STATES.WALK
		animator.play("WALK")
		floor_checker.force_raycast_update()
		velocity.x = direction*move_speed
		state = STATES.WALK
