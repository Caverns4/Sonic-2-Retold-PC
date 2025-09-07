extends CharacterBody2D

var parent = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !parent:
		velocity.y += delta*9.8*60
		move_and_slide()
		if global_position.y > 2048:
			queue_free()
