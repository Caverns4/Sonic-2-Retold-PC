extends EnemyBase

var Projectile = preload("res://Entities/Enemies/Projectiles/GenericProjectile.tscn")
@export var bulletSound = preload("res://Audio/SFX/Objects/s2br_Projectile.wav")

@export_enum("Stay","Flee") var behavior = 0

#Object state controllers
enum STATES{IDLE,JUMP,HOVER,LAND,FLEE}
var state = 0

var targets = [] # targets in the sensor area
var lookingForTargets = false # If the enemy is scanning for a target.
var currentTarget = null # The target picked from targets. used to remember the player.

@onready var animator = $AnimationPlayer
@onready var bulletPoint = $Sprite2D/BulletPoint

var stateTimer = 0.0
var direction = 1

const SCAN_TIME = 		(30.0/60.0) # Time to wait before jumping
const JUMP_TIME = 		0.5 # Time to wait after jumping before firing
const COOLDOWN_TIME =	0.26 # Time to idle before trying to land.
const GRAVITY = 300
const JUMP_VEL = -100
const ESCAPE_VEL = 600

func _ready() -> void:
	$PlayerCheck.visible = true
	lookingForTargets = true
	super()

func _process(delta: float) -> void:
	super(delta)

func _physics_process(delta: float) -> void:
	if stateTimer > 0.0:
		stateTimer = max(0.0,(stateTimer - delta))
	
	match state:
		STATES.IDLE:
			MoveWithGravity(delta)
			if lookingForTargets and targets.size() > 0:
				LookAtPlayer()
				lookingForTargets = false
				stateTimer = SCAN_TIME
			if lookingForTargets == false and stateTimer == 0.0:
				if !targets:
					lookingForTargets = true
				else:
					state = STATES.JUMP
					velocity.y = JUMP_VEL
					animator.play("JUMP")
					position.y -= 6
					#print("Jump")
		STATES.JUMP:
			MoveWithGravity(delta)
			if velocity.y >= 0.0:
				state = STATES.HOVER
				velocity = Vector2.ZERO
				animator.play("HOVER_ANGRY")
				stateTimer = JUMP_TIME
				LookAtPlayer()
		STATES.HOVER:
			if stateTimer == 0.0:
				shootBullet()
				animator.play("HOVER")
				stateTimer = JUMP_TIME
				if !behavior:
					state = STATES.LAND
				else:
					state = STATES.FLEE
					$VisibleOnScreenEnabler2D.queue_free()
		STATES.LAND:
			if stateTimer == 0.0:
				MoveWithGravity(delta)
			if is_on_floor():
				state = STATES.IDLE
				animator.play("RESET")
				lookingForTargets = true
				stateTimer = SCAN_TIME
		STATES.FLEE:
			if stateTimer == 0.0:
				velocity.x = (direction * ESCAPE_VEL)

func MoveWithGravity(delta):
	# Velocity movement
	set_velocity(velocity)
	set_up_direction(Vector2.UP)
	move_and_slide()
	# Gravity
	if !is_on_floor():
		velocity.y += GRAVITY*delta

func SpeedToPos(delta):
	# Velocity movement
	set_velocity(velocity)
	move_and_slide()

func shootBullet():
	# Shoot stabdard bullet
	SoundDriver.play_sound(bulletSound)
	var bullet = Projectile.instantiate()
	get_parent().add_child(bullet)
	# set position with offset
	bullet.global_position = bulletPoint.global_position
	bullet.scale.x = 1
	bullet.velocity.x = 0-(direction * 120)

func LookAtPlayer():
	var nearestPlayer = GlobalFunctions.get_nearest_player_x(global_position.x)
	if nearestPlayer and nearestPlayer.global_position.x > global_position.x:
		direction = -1
	else: #If a player was not found, or is left.
		direction = 1
	$Sprite2D.scale.x = direction
	if nearestPlayer.isSuper:
		behavior = 1 #Flee

func _on_player_check_body_entered(body: Node2D) -> void:
	targets.append(body)


func _on_player_check_body_exited(body: Node2D) -> void:
	targets.erase(body)
