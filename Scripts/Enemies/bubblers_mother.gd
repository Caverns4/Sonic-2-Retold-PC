extends EnemyBase

var projectile = preload("res://Entities/Enemies/Bubbler.tscn")
var bullet = null
var bubble_timer: float = 0.0

func _ready() -> void:
	velocity.x = -30
	super()

func _physics_process(delta: float) -> void:
	bubble_timer -= delta
	
	var player = GlobalFunctions.get_nearest_player_x(global_position.x)
	var result = absf(global_position.x - (player.global_position.x))
	if result < 128 and bubble_timer <= 0.0:
		bullet = projectile.instantiate()
		get_parent().add_child(bullet)
		bullet.global_position = global_position + Vector2(0,8)
		bubble_timer = 3.0
