extends EnemyBase

const GRAVITY = 600

@export_enum("HIDE","WANDER") var behavior: int = 0
@export_enum("Left","Right")var direction: int = 0
@export var idle_time: float = 1.0
@export var move_speed: float = 60

var diggingParticle: PackedScene = preload("res://Entities/Misc/GenericParticle.tscn")
var breakingSound: AudioStream = preload("res://Audio/SFX/Gimmicks/s2br_Collapse.wav")

#Two types of behavior.
#1: Move left and right until reaching a ledge.
#2: Hide in wall until player enters the area, then break through
enum STATES{WALK,IDLE,HIDDEN}
var state: STATES = STATES.WALK

@onready var bricks: Array[Sprite2D] = [$BrickA,$BrickB,$BrickC,$BrickD]

@onready var sprite_node: AnimatedSprite2D = $Grounder
@onready var floor_checker: RayCast2D = $Grounder/FloorCheck
@onready var state_time: Timer = $Timers/StateTime


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direction = (direction*2)-1
	super()
	if behavior != 0:
		for i in bricks.size():
			bricks[i].queue_free()
		bricks.clear()
		$PlayerCheck.queue_free()
		_change_direction(move_speed)
	else:
		state = STATES.HIDDEN
		$DamageArea.monitoring = false
		for i in bricks.size():
			bricks[i].show()
		sprite_node.play("hide")
	state_time.connect("timeout",_on_idle_time_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if state >= STATES.HIDDEN:
		return
	match state:
		STATES.WALK:
			EdgeCheck()
		STATES.IDLE:
			pass
	if !is_on_floor():
		velocity.y += (GRAVITY*delta)
	move_and_slide()

func EdgeCheck() -> void:
	if (is_on_wall() or !floor_checker.is_colliding()):
		velocity.x = 0.0
		state_time.start(idle_time)
		state = STATES.IDLE
		sprite_node.play("default")

func _change_direction(speed: float) -> void:
	direction = -direction
	sprite_node.scale.x = 0-sign(direction)
	floor_checker.force_raycast_update()
	velocity.x = speed*direction
	state = STATES.WALK
	sprite_node.play("walk")

func _on_player_check_body_entered(_body: Node2D) -> void:
	sprite_node.play("hide2")
	for i in bricks.size():
		var node: Sprite2D = bricks[i]
		var debris: Node2D = diggingParticle.instantiate()
		debris.global_position = node.global_position
		debris.play("ARZRocks")
		get_parent().add_child(debris)
		node.queue_free()
	bricks.clear()
	SoundDriver.play_sound(breakingSound)
	$PlayerCheck.queue_free()
	

func _on_grounder_sprite_2d_animation_finished() -> void:
	if sprite_node.animation == "hide2":
		sprite_node.play("walk")
		state = STATES.WALK
		velocity.x = move_speed * direction
		$DamageArea.monitoring = true

func _on_idle_time_timeout() -> void:
	_change_direction(move_speed)
