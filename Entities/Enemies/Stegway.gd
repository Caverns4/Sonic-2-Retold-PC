extends EnemyBase

const WALK_SPEED = 60 # 1 pixel per frame
const DASH_SPEED = 240 # 4 pixels per frame
const IDLE_TIME = 1.0
const GRAVITY = 600
const DASH_CHARGE_TIME = 0.5 #Time to rev before charaging a player

@onready var animator = $SpriteNode/AnimationPlayer
var revSound = preload("res://Audio/SFX/Player/SpindashRev.wav")

enum STATES{WALK,IDLE,CHARGE}
var state = 0
var stateTimer = 0
var direction = 1
var dashMem = false

# Physics variables
var ground = false
var movement = Vector2.ZERO
var targets = []

func _ready() -> void:
	defaultMovement = false
	$VisibleOnScreenEnabler2D.visible = true
	$SpriteNode/PlayerCheck.visible = true
	$SpriteNode/Flame.visible = false

func _physics_process(delta: float) -> void:
	stateTimer -= delta
	# Direction checks
	$SpriteNode.scale.x = abs($SpriteNode.scale.x)*-sign(direction)
	$FloorCheck.position.x = abs($FloorCheck.position.x)*(direction)
	$FloorCheck.force_raycast_update()
	
	match state:
		STATES.IDLE:
			if stateTimer <= 0.0:
				state = STATES.WALK
				direction = -direction
				position.x += direction
				movement.x = direction*WALK_SPEED
				animator.play("WALK")
		STATES.CHARGE:
			if stateTimer <= 0.0 and !dashMem:
				movement.x = direction*DASH_SPEED
				animator.play("DASH")
				dashMem = true
				$SpriteNode/Flame.visible = true
			EdgeCheck()
		_: # Walk
			if targets:
				var waitTime = DASH_CHARGE_TIME
				
				for i in targets.size():
					var node = targets[i]
					if (node.get("supTime") != null):
						if (node.supTime > 0):
							direction = sign(global_position.x - node.global_position.x)
							waitTime = DASH_CHARGE_TIME/2.0
							#print(direction)
				movement.x = 0
				stateTimer = waitTime
				animator.play("CHARGE")
				state = STATES.CHARGE
				Global.play_sound(revSound)
			# Edge check
			EdgeCheck()
	
	MoveWithGravity(delta)

func EdgeCheck():
	# Edge check
	if (is_on_wall() or !$FloorCheck.is_colliding()):
		stateTimer = IDLE_TIME
		state = STATES.IDLE
		movement.x = 0
		animator.play("RESET")
		dashMem = false
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


func _on_player_check_body_entered(body: Node2D) -> void:
	targets.append(body)


func _on_player_check_body_exited(body: Node2D) -> void:
	targets.erase(body)
