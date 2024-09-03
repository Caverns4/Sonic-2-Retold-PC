extends EnemyBase

const WALK_SPEED = 60
const IDLE_TIME = 1.0
const GRAVITY = 600

enum STATES{WALK,IDLE,SHOOT}

var direction = 1
var state = STATES.WALK
var stateTimer = 0

var ground = false

var Particle = preload("res://Entities/Misc/GenericParticle.tscn")
@onready var animator = $AnimationPlayer

func _ready():
	defaultMovement = false
	direction = -sign(scale.x)
	$VisibleOnScreenEnabler2D.visible = true
	animator.play("WALK")

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
		STATES.IDLE:
			stateTimer -= delta
			if stateTimer <= 0.0:
				state = STATES.WALK
				animator.play("WALK")
				direction = -direction
				position.x += direction
		STATES.SHOOT:
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
