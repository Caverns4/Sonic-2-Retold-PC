extends EnemyBase

const GRAVITY = 600
const IDLE_TIME = 1.0

enum STATES{WALK,IDLE,CHARGE}
var state = 0
var stateTimer = 0

# Physics variables
var ground = false
var movement = Vector2.ZERO
var direction = 1
var animTime = 0

#Object variables
var targets = [] #Player objects, if any are detected.
var Particle = preload("res://Entities/Misc/GenericParticle.tscn")

func _ready():
	defaultMovement = false
	direction = -sign(scale.x)
	scale.x = 1
	movement.x = direction*30
	$VisibleOnScreenEnabler2D.visible = true
	$SpriteNode/PlayerCheck.visible = true
	$SpriteNode/Flame.visible = false
	super()

func _physics_process(delta):
	stateTimer -= delta
	# Direction checks
	$SpriteNode.scale.x = abs($SpriteNode.scale.x)*-sign(direction)
	$FloorCheck.position.x = abs($FloorCheck.position.x)*direction
	$FloorCheck.force_raycast_update()
	
	match state:
		STATES.IDLE:
			if stateTimer <= 0.0:
				state = STATES.WALK
				direction = -direction
				position.x += direction
				movement.x = direction*30
		STATES.CHARGE:
			animTime = fmod(animTime+delta*4,1)
			EdgeCheck()
			AnimateSmoke(delta)
		_: #Walking
			animTime = fmod(animTime+delta*2,1)
			if targets:
				movement.x = direction*120
				$SpriteNode/Flame.visible = true
				state = STATES.CHARGE
			# Edge check
			EdgeCheck()
	
	#Animate main sprite
	$SpriteNode/Motobug.frame = round(fmod(animTime,1))
	MoveWithGravity(delta)

func EdgeCheck():
	# Edge check
	if (is_on_wall() or !$FloorCheck.is_colliding()):
		stateTimer = IDLE_TIME
		state = STATES.IDLE
		movement.x = 0
		animTime = 0
		$SpriteNode/Flame.visible = false
		direction = clamp(direction,-1,1)

func MoveWithGravity(delta):
	# Velocity movement
	set_velocity(movement)
	set_up_direction(Vector2.UP)
	move_and_slide()
	ground = is_on_floor()
	# Gravity
	if !is_on_floor():
		movement.y += (GRAVITY*delta)

	# Moto bug smoke
func AnimateSmoke(delta):
	if fmod(animTime+delta*2,1) < animTime:
		var part = Particle.instantiate()
		get_parent().add_child(part)
		part.global_position = global_position-(Vector2(24,-2)*direction)
		part.play("MotoBugSmoke")

func _on_player_check_body_entered(body: Node2D) -> void:
	targets.append(body)

func _on_player_check_body_exited(body: Node2D) -> void:
	targets.erase(body)
