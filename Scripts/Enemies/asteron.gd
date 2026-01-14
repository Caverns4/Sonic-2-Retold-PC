extends EnemyBase

@export var movement_time: float = 1.0

var target_position: Vector2 = Vector2.ZERO
var Projectile = preload("res://Entities/Enemies/Projectiles/AsteronProjectile.tscn")

var bullet_stats: Array[Vector2] = [
	Vector2(0,-360),
	Vector2(-360,0),
	Vector2(360,0),
	Vector2(-120,240),
	Vector2(120,240),
]

@onready var _timer: Timer = $Timer

func _ready() -> void:
	_timer.wait_time = movement_time
	super()

func _physics_process(delta: float) -> void:
	var test = GlobalFunctions.get_orientation_to_player(global_position)
	if test.length() < 96 and !target_position:
		target_position = test+global_position
		_timer.start(movement_time)
	
	if target_position:
		global_position = global_position.move_toward(target_position,20*delta)
	
	move_and_slide()


func _on_timer_timeout() -> void:
	for i in bullet_stats.size():
		var bullet: CharacterBody2D = Projectile.instantiate()
		get_parent().add_child(bullet)
		# set position with offset
		for child in bullet.get_children():
			if child is Sprite2D:
				child.frame = i
		bullet.global_position = global_position
		bullet.velocity = bullet_stats[i]
		bullet.z_index = z_index
	destroy()
