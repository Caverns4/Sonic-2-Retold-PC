extends EnemyBase

const GRAVITY = 600
@export var idle_time: float = 1.0
@export var move_speed: float = 30

@onready var floor_checker: RayCast2D = $SpriteNode/FloorCheck
@onready var state_time: Timer = $Timers/IdleTime

enum STATES{WALK,IDLE,CHARGE}
var state: STATES = STATES.WALK

# Physics variables
var direction: int = 1
var animTime: float = 0

#Object variables
var targets: Array[Player2D] = [] #Player objects, if any are detected.
var Particle: PackedScene = preload("res://Entities/Misc/GenericParticle.tscn")

func _ready() -> void:
	velocity.x = direction*30
	$VisibleOnScreenEnabler2D.visible = true
	$SpriteNode/Flame.visible = false
	super()

func _physics_process(delta: float) -> void:
	match state:
		STATES.CHARGE:
			animTime = fmod(animTime+delta*4,1)
			$SpriteNode/Motobug.frame = round(fmod(animTime,1))
			EdgeCheck()
			AnimateSmoke(delta)
		STATES.WALK:
			animTime = fmod(animTime+delta*2,1)
			$SpriteNode/Motobug.frame = round(fmod(animTime,1))
			if targets:
				velocity.x = direction*move_speed*4
				$SpriteNode/Flame.visible = true
				state = STATES.CHARGE
			# Edge check
			EdgeCheck()
	#Animate main sprite
	$SpriteNode/Motobug.frame = round(fmod(animTime,1))
	if !is_on_floor():
		velocity.y += (GRAVITY*delta)
	move_and_slide()

func EdgeCheck() -> void:
	#floor_checker.force_raycast_update()
	if (is_on_wall() or !floor_checker.is_colliding()):
		state_time.start(idle_time)
		state = STATES.IDLE
		velocity.x = 0
		animTime = 0
		$SpriteNode/Flame.visible = false

	# Moto bug smoke
func AnimateSmoke(delta: float) -> void:
	if fmod(animTime+delta*2,1) < animTime:
		var part: Node2D = Particle.instantiate()
		get_parent().add_child(part)
		part.global_position = global_position-(Vector2(24,-2)*direction)
		part.play("MotoBugSmoke")

func _on_player_check_body_entered(body: Node2D) -> void:
	targets.append(body)

func _on_player_check_body_exited(body: Node2D) -> void:
	targets.erase(body)

func _on_idle_time_timeout() -> void:
	if state == STATES.IDLE:
		direction = -direction
		$SpriteNode.scale.x = abs($SpriteNode.scale.x)*-sign(direction)
		floor_checker.force_raycast_update()
		velocity.x = direction*move_speed
		state = STATES.WALK
