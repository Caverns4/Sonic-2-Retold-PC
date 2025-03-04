@tool
extends Node2D

## The direction the bridge will rotate when acivated.
@export_enum("Counter-Clockwise","Clockwise") var rotateDirection = 0

var trigger = false
var intialRotation = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Become either 1 or -1
	rotateDirection = rotateDirection*2-1
	intialRotation = rotation_degrees


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for child in get_children():
		var next = child.find_child("Sprite2D",false)
		next.global_position = child.global_position
		
	if !Engine.is_editor_hint() and trigger:
		rotation_degrees = move_toward(
			rotation_degrees,
			intialRotation+(90*rotateDirection),
			delta*64)

func Trigger():
	trigger = true
	pass
