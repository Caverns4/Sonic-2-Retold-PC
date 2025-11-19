extends EnemyBase

## Blue model takes longer to throw slicers
@export_enum("Blue","Green","Red") var model: int = 0
@export var move_speed: float = 15
@export var walk_time: float = 5.0
@export var slicer_tracking_time: float = 4.0

const THROW_DELAY = [1.0,0.5,0.25,1.0]

enum STATE{WALK,WAIT,THROW}
var state: int = 0
var state_time: float = 1.0
var throw_time: float = 999
var move_dir: int = -1
var thrown: bool = false
var projectile = preload("res://Entities/Enemies/Projectiles/SlicerProjectile.tscn")

@onready var colorMask = $Sprite2D/ColorMask
@onready var sprite = $Sprite2D
@onready var _animation:AnimationPlayer = $AnimationPlayer

var players: Array[Player2D] = []

func _ready() -> void:
	velocity.x = 0-(move_speed*sign(scale.x))
	_animation.play("Walk")
	state_time = walk_time
	match model:
		0:
			colorMask.visible = true
			colorMask.self_modulate = Color("4444ff",1.0)
		2:
			colorMask.self_modulate = Color("ff0000",1.0)
			colorMask.visible = true
		_:
			colorMask.queue_free()
	super()

func _physics_process(delta: float) -> void:
	ScanForPlayers()
	match state:
		STATE.WALK:
			state_time -= delta
			ScanForPlayers()
			
			if players:
				_animation.play("AIM")
				state = STATE.THROW
				throw_time = THROW_DELAY[model]
				velocity.x = 0
			elif state_time <= 0.0:
				_animation.play("RESET")
				state = STATE.WAIT
				state_time = 0.1
				velocity.x = 0
		STATE.WAIT:
			state_time -= delta
			if state_time <= 0.0:
				state = STATE.WALK
				state_time = walk_time
				move_dir = 0-move_dir
				velocity.x = move_speed*move_dir
				_animation.play("Walk")
		STATE.THROW:
			ScanForPlayers()
			if !players and !thrown:
				state = STATE.WALK
				velocity.x = move_speed*move_dir
				_animation.play("Walk")
			elif !thrown:
				throw_time -= delta
				if throw_time <= 0.0:
					%ClawL.queue_free()
					%ClawR.queue_free()
					thrown = true
					_throw_bullet()
	
	if !is_on_floor():
		velocity.y += 9.8*delta
	move_and_slide()
	
	if is_on_wall() and state == STATE.WALK:
		move_dir = 0-move_dir
		velocity.x = move_speed*move_dir
	updateSprite()

func ScanForPlayers():
	players.clear()
	var nearest = GlobalFunctions.get_nearest_player(global_position)
	#var nearest = GlobalFunctions.get_nearest_player_x(global_position.x)
	var diff = nearest.global_position.x - global_position.x
	if (abs(diff) <= 160 ): #and sign(diff) == sign(move_dir)
		players.append(nearest)

func updateSprite():
	if round(velocity.x) != 0:
		sprite.scale.x = 0-sign(velocity.x)
	var wrColor = weakref(colorMask).get_ref()
	if wrColor: 
		colorMask.frame = sprite.frame

func _throw_bullet():
	var bullet: EnemyProjectileBase = projectile.instantiate()
	add_child(bullet)
	bullet.reparent(get_parent())
	bullet.global_position = global_position
	bullet.move_dir = move_dir
	bullet.slicer_tracking_time = slicer_tracking_time
	bullet.velocity.x = 120*sign(move_dir)
	bullet.target = players[0]
	bullet.parent = self
