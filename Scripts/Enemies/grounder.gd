extends EnemyBase

@export_enum("HIDE","WANDER") var behavior = 0

var diggingParticle = preload("res://Entities/Misc/GenericParticle.tscn")
var breakingSound = preload("res://Audio/SFX/Gimmicks/Collapse.wav")

const WALK_SPEED = 60
const IDLE_TIME = 1.0
const GRAVITY = 600

#Two types of behavior.
#1: Move left and right until reaching a ledge.
#2: Hide in wall until player enters the area, then break through
enum STATES{WALK,IDLE,HIDDEN}
var state = STATES.WALK

var stateTimer = 0
var direction = -1
var ground = false

@onready var bricks = [$BrickA,$BrickB,$BrickC,$BrickD]
@onready var grounder = $GrounderSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	defaultMovement = false
	$VisibleOnScreenEnabler2D.visible = true
	if behavior != 0:
		for i in bricks.size():
			bricks[i].queue_free()
		bricks = []
		$PlayerCheck.queue_free()
		$DamageArea.monitoring = true
		state = STATES.WALK
		velocity.x = WALK_SPEED * direction
		grounder.play("walk")
	else:
		for i in bricks.size():
			bricks[i].show()
		state = STATES.HIDDEN
		grounder.play("hide")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if state >= STATES.HIDDEN:
		return
	
	$GrounderSprite2D.scale.x = 0-direction
	$FloorCheck.position.x = 14*direction
	$FloorCheck.force_raycast_update()
	match state:
		STATES.WALK:
			velocity.x = direction*WALK_SPEED
			if (is_on_wall() or !$FloorCheck.is_colliding()):
				stateTimer = IDLE_TIME
				state = STATES.IDLE
				grounder.play("default")
				velocity.x = 0
		STATES.IDLE:
			stateTimer -= delta
			if stateTimer <= 0.0:
				state = STATES.WALK
				grounder.play("walk")
				direction = -direction
				position.x += direction
	MoveWithGravity(delta)


func MoveWithGravity(delta):
	# Velocity movement
	#set_velocity(velocity)
	set_up_direction(Vector2.UP)
	move_and_slide()
	ground = is_on_floor()
	# Gravity
	if !ground:
		velocity.y += GRAVITY*delta

func _on_player_check_body_entered(body: Node2D) -> void:
	$PlayerCheck.queue_free()
	grounder.play("hide2")
	for i in bricks.size():
		var node = bricks[i]
		var debris = diggingParticle.instantiate()
		debris.global_position = node.global_position
		debris.play("ARZRocks")
		get_parent().add_child(debris)
		node.queue_free()
	bricks = []
	Global.play_sound(breakingSound)
	


func _on_grounder_sprite_2d_animation_finished() -> void:
	if grounder.animation == "hide2":
		grounder.play("walk")
		state = STATES.WALK
		velocity.x = WALK_SPEED * direction
		$DamageArea.monitoring = true
