extends EnemyBase

## Number of projectiles this Aquis can fire before being empty.
@export var bulletCount: int = 3
@export var bulletSound = preload("res://Audio/SFX/Objects/s2br_Projectile.wav")

var Projectile = preload("res://Entities/Enemies/Projectiles/AquisProjectile.tscn")
var bullet = null

## Movement seed cap
const SPEED = 60.0
const ACCEL = 6*60

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
		STATE.CHASE:
			stateTime -= delta
			var player = GetClosestPlayer()
			if player:
				velocity.x += (ACCEL*delta) * sign(player.global_position.x-global_position.x)
				velocity.y += (ACCEL*delta) * sign(player.global_position.y-global_position.y)
				velocity.x = clampf(velocity.x,-SPEED,SPEED)
				velocity.y = clampf(velocity.y,-SPEED,SPEED)
			LookInMoveDirection()
			if stateTime < 0.0:
				state = STATE.SHOOTING
				velocity = Vector2.ZERO
				stateTime = 0.5 #Shoot a bullet soon.
		STATE.SHOOTING:
			stateTime -= delta
			if stateTime < 0.0:
				if bulletCount > 0:
					state = STATE.CHASE
					stateTime = 2.13
					velocity.y = -60.0
					shootFlag = false
				else:
					$Aquis_Sprite.scale.x = direction
					velocity.x = SPEED*2*direction
					state = STATE.FLEE
		STATE.FLEE:
			pass
	move_and_slide()
	$Aquis_Sprite.global_position = round(global_position)


func LookInMoveDirection():
	if velocity.x != 0:
		direction = 0-sign(velocity.x)
		$Aquis_Sprite.scale.x = direction
		

func GetClosestPlayer():
	#Return the nearest player by x_pos
	var j = 0 #last x_position result
	var closest = null #closest x distance
	var finalObj = null #Output object
	for i in Global.players: #number of applicable players
		j = global_position.distance_to(i.global_position)
		
		if !closest or closest > j:
			closest = j
			finalObj = i
	return finalObj
