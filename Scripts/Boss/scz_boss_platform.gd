extends StaticBody2D

@export var controller: BossBase = null
var is_moving: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if controller:
		controller.boss_defeated.connect(begin_descent)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global_position.y >= 4096:
		queue_free()
	elif is_moving:
		global_position.y = move_toward(global_position.y,10000,delta*8)
		$Sprite2D.global_position.y = roundi(global_position.y)

func begin_descent() -> void:
	is_moving = true
