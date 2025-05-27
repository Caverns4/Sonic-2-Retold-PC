extends Node2D

var parent = null
var velocity = Vector2.ZERO
var chain_length = 8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if global_position.y > 2048:
		queue_free()
