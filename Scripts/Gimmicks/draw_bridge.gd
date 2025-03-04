@tool
extends Node2D

## The direction the bridge will rotate when acivated.
@export_enum("Counter-Clockwise","Clockwise") var RotateDirection = 0

var trigger = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for child in get_children():
		var next = child.find_child("Sprite2D",false)
		next.global_position = child.global_position
		
	if Engine.is_editor_hint():
		pass
	else:
		pass
