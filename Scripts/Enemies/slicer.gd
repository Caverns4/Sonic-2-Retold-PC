extends EnemyBase

## Blue model takes longer to throw slicers
@export_enum("Blue","Green","Red") var model: int = 0
@export var move_speed = 15
@export var walk_time = 1.0
@export var cooldown_time = 2.0

const BLUE_TIMER: float = 1.0
const GREEN_TIMER: float = 0.5
const RED_TIMER: float = 0.1

enum  STATE{WALK,WAIT,THROW}
var state: int = 0
var state_time: float = 1.0
var move_dir: int = -1
var thrown: bool = false
var projectile = preload("res://Entities/Enemies/Projectiles/SlicerProjectile.tscn")

@onready var colorMask = $Sprite2D/ColorMask
@onready var sprite = $Sprite2D
@onready var _animation:AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	velocity.x = 0-(move_speed*sign(scale.x))
	_animation.play("Walk")
	match model:
		0:
			colorMask.self_modulate = Color("4444ff",1.0)
		2:
			colorMask.self_modulate = Color("ff0000",1.0)
		_:
			colorMask.visible = false
	super()

func _physics_process(delta: float) -> void:
	match state:
		STATE.WALK:
			state_time -= delta
			var look_at = GlobalFunctions.get_orientation_to_player(global_position)
			
			if state_time <= 0.0:
				_animation.play("RESET")
				state = STATE.WAIT
				state_time = 1.0
				cooldown_time = 2.0
				velocity.x = 0
		STATE.WAIT:
			state_time -= delta
			cooldown_time -= delta
			if state_time <= 0.0:
				state = STATE.WALK
				state_time = walk_time
				move_dir = 0-move_dir
				velocity.x = move_speed*move_dir
				_animation.play("Walk")
	
	if !is_on_floor():
		velocity.y += 9.8*delta
	move_and_slide()
	if is_on_wall() and state == STATE.WALK:
		move_dir = 0-move_dir
		velocity.x = move_speed*move_dir
	updateSprite()
	

func updateSprite():
	if round(velocity.x) != 0:
		sprite.scale.x = 0-sign(velocity.x)
	colorMask.frame = sprite.frame
