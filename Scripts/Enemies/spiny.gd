extends EnemyBase

@export var bulletSound = preload("res://Audio/SFX/Objects/s2br_Projectile.wav")

const SPEED = 25.0 #Walk speed
const MAX_MOVE_TIME = 4.0 #time to move in each direction
const SHOOT_WAIT_TIME = 2.0

var targets = [] # targets in the sensor area
var currentTarget = null # The target picked from targets. used to remember the player.

var Projectile = preload("res://Entities/Enemies/Projectiles/GenericProjectile.tscn")
var bullet = null

@onready var bulletPoint = $Sprite2D/BulletPoint
@onready var animator = $AnimationPlayer

var moveTimer = 0.0
var shootTime = 0.0
var shootMemoryFlag = false
var velocityPreVec = Vector2.ZERO #Movement speed before Vector is rortated

func _ready() -> void:
	velocityPreVec.x = SPEED
	moveTimer = MAX_MOVE_TIME/2.0
	animator.play("WALK")
	$VisibleOnScreenEnabler2D.visible = true
	$PlayerCheck.visible = true
	super()

func _physics_process(delta: float) -> void:
	if !shootTime > 0.0:
		if moveTimer > 0.0:
			moveTimer -= delta
		else:
			moveTimer = MAX_MOVE_TIME
			velocityPreVec.x = 0-velocityPreVec.x
			shootMemoryFlag = false

		velocity = Vector2(velocityPreVec).rotated(rotation)
		if targets and shootMemoryFlag == false:
			currentTarget = GlobalFunctions.get_nearest_player_x(global_position.x)
			shootTime = SHOOT_WAIT_TIME
			velocity = Vector2.ZERO
			animator.play("RESET")
	else:
		shootTime -= delta
		if shootTime < 1.0 and shootMemoryFlag == false:
			animator.play("SHOOT")
			shootBullet()
			shootMemoryFlag = true
		elif shootTime <= 0.0:
			animator.play("WALK")

func shootBullet():
	# Shoot stabdard bullet
	bullet = Projectile.instantiate()
	get_parent().add_child(bullet)
	# set position with offset
	bullet.gravity = true
	bullet.global_position = bulletPoint.global_position
	Global.play_sound(bulletSound)
	
	var temp = Vector2(0,-150).rotated(rotation)
	if rotation == 0:
		var balance = sign(currentTarget.global_position.x - global_position.x)
		temp = Vector2(0,150).rotated(balance * -40)
	bullet.velocity = temp


func _on_player_check_body_entered(body: Node2D) -> void:
	targets.append(body)


func _on_player_check_body_exited(body: Node2D) -> void:
	targets.erase(body)
