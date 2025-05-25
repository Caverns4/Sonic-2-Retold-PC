extends EnemyBase

## Number of projectiles this Aquis can fire before being empty.
@export var bulletCount: int = 3
@export var bulletSound = preload("res://Audio/SFX/Objects/s2br_Projectile.wav")

@onready var bulletPoint = %BulletPoint
@onready var animator = $AnimationPlayer

var Projectile = preload("res://Entities/Enemies/Projectiles/AquisProjectile.tscn")
var bullet = null

## Movement seed cap
const SPEED = 60.0
const ACCEL = 2*60

enum STATE{CHECKSCREEN,CHASE,SHOOTING,FLEE}
var state: int = STATE.CHECKSCREEN
var stateTime: float = 0.0
var shootFlag: bool = false
var direction: int = -1

func _ready() -> void:
	defaultMovement = false
	super()

func _physics_process(delta: float) -> void:
	match  state:
		STATE.CHECKSCREEN:
			if $VisibleOnScreenNotifier2D.is_on_screen():
				state = STATE.CHASE
				animator.play("float")
		STATE.CHASE:
			stateTime -= delta
			var player = GetClosestPlayer()
			if player:
				#Do it this way instead of move_toward so the vector will not normalize.
				velocity.x += (ACCEL*delta) * sign(player.global_position.x-global_position.x)
				velocity.y += (ACCEL*delta) * sign(player.global_position.y-global_position.y)
				velocity.x = clampf(velocity.x,-SPEED,SPEED)
				velocity.y = clampf(velocity.y,-SPEED,SPEED)
			LookInMoveDirection()
			if stateTime < 0.0:
				state = STATE.SHOOTING
				velocity = Vector2.ZERO
				stateTime = 0.5 #Shoot a bullet soon.
				animator.play("spit")
			else:
				FleeIfSuper()
		STATE.SHOOTING:
			stateTime -= delta
			if stateTime < 0.0:
				shootBullet()
				if bulletCount > 0:
					animator.play("float")
					state = STATE.CHASE
					stateTime = 2.13
					velocity.y = -120.0
					shootFlag = false
				else:
					animator.play("float")
					velocity.x = (SPEED*3)*direction
					LookInMoveDirection()
					state = STATE.FLEE
			else:
				FleeIfSuper()
		STATE.FLEE:
			if !$VisibleOnScreenNotifier2D.is_on_screen():
				queue_free()
	move_and_slide()
	$Aquis_Sprite.global_position = round(global_position)

func shootBullet():
	if shootFlag:
		return
	shootFlag = true
	#Find nearest player.
	var nearestPlayer = GlobalFunctions.get_nearest_player(global_position)
	# Do not shoot of player is above.
	if nearestPlayer and nearestPlayer.global_position.y < global_position.y:
		return
	bulletCount -= 1
	# If we've made it this far, shoot
	if $VisibleOnScreenNotifier2D.is_on_screen():
		Global.play_sound(bulletSound)
	bullet = Projectile.instantiate()
	get_parent().add_child(bullet)
	# set position with offset
	bullet.global_position = bulletPoint.global_position
	bullet.scale.x = 1
	bullet.velocity.x = 0-(direction * 180)
	bullet.velocity.y = 120

func LookInMoveDirection():
	if velocity.x != 0:
		direction = 0-sign(velocity.x)
		$Aquis_Sprite.scale.x = direction

func FleeIfSuper():
	if Global.players.size() > 0 and Global.players[0].isSuper:
		var player = GlobalFunctions.get_nearest_player(global_position)
		if player:
			animator.play("float")
			direction = sign(global_position.x - player.global_position.x)
			if direction == 0:
				direction = 1
			velocity.x = SPEED*2*direction
			LookInMoveDirection()
			state = STATE.FLEE
