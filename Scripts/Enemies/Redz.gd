extends EnemyBase

const WALK_SPEED = 60
const IDLE_TIME = 1.0
const GRAVITY = 600


var Projectile = preload("res://Entities/Enemies/Projectiles/RedzFire.tscn")
var bullet = null
var bulletSound = preload("res://Audio/SFX/Objects/s2br_Flamethrower.wav")

enum STATES{WALK,IDLE,SHOOT}

var state = STATES.WALK
var direction = 1
var stateTimer = 0
var shootTimer = 0.0

var ground = false

var targets = []

var Particle = preload("res://Entities/Misc/GenericParticle.tscn")
@onready var animator = $AnimationPlayer
@onready var bulletPoint = $Redz/BulletPoint

func _ready():
	defaultMovement = false
	direction = -sign(scale.x)
	$VisibleOnScreenEnabler2D.visible = true
	$Redz/PlayerCheck.visible = true
	animator.play("WALK")
	global_scale = Vector2(1,1)
	

func _physics_process(delta):
	# Dirction checks
	$Redz.scale.x = abs($Redz.scale.x)*-direction
	$FloorCheck.position.x = abs($FloorCheck.position.x)*direction
	$FloorCheck.force_raycast_update()
	
	match state:
		STATES.WALK:
			velocity.x = direction*WALK_SPEED
			# Edge check
			if (is_on_wall() or !$FloorCheck.is_colliding()):
				stateTimer = IDLE_TIME
				state = STATES.IDLE
				animator.play("RESET")
				velocity.x = 0
				if targets:
					state = STATES.SHOOT
					animator.play("SHOOT")
		STATES.IDLE:
			stateTimer -= delta
			if stateTimer <= 0.0:
				state = STATES.WALK
				animator.play("WALK")
				direction = -direction
				position.x += direction
		STATES.SHOOT:
			stateTimer -= delta
			if !animator.is_playing():
				state = STATES.IDLE
				animator.play("RESET")
			else:
				shootBullet(delta)
			
			# Redz fire spit (Todo)
			#if fmod(animTime+delta*2,1) < animTime:
			#	var part = Particle.instantiate()
			#	get_parent().add_child(part)
			#	part.global_position = global_position-(Vector2(24,-2)*direction)
			#	part.play("MotoBugSmoke")
			pass
	MoveWithGravity(delta)

func MoveWithGravity(delta):
	# Velocity movement
	set_velocity(velocity)
	# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `Vector2.DOWN`
	set_up_direction(Vector2.UP)
	move_and_slide()
	ground = is_on_floor()
	# Gravity
	if !is_on_floor():
		velocity.y += GRAVITY*delta

func shootBullet(delta):
	shootTimer+=delta
	if shootTimer >= 0.05:
		shootTimer=0.0
		#Shoot a fireball
		Global.play_sound(bulletSound)
		bullet = Projectile.instantiate()
		get_parent().add_child(bullet)
		# set position with offset
		bullet.global_position = bulletPoint.global_position
		bullet.scale.x = 1
		bullet.velocity.x = (direction * 120)
		bullet.velocity.y = (stateTimer*80) - 28

func _on_player_check_body_entered(body: Node2D) -> void:
	targets.append(body)


func _on_player_check_body_exited(body: Node2D) -> void:
	targets.erase(body)
