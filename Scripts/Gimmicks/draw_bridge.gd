@tool
extends Node2D

## The direction the bridge will rotate when acivated.
@export_enum("Counter-Clockwise","Clockwise","Open") var behavior = 0
@export var sfx: AudioStream = preload("res://Audio/SFX/Gimmicks/s2br_Drawbridge_Drop.wav")

var trigger = false
var intialRotation = 0.0
var rotateDirection = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Become either 1 or -1
	rotateDirection = behavior*2-1
	intialRotation = rotation_degrees


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !Engine.is_editor_hint() and trigger:
		if behavior <= 1:
			rotation_degrees = move_toward(
				rotation_degrees,
				intialRotation+(90*rotateDirection),
				delta*192)
		else:
			$LeftSegments.rotation_degrees = move_toward(
				$LeftSegments.rotation_degrees,
				90,
				delta*192)
			$RightSegments.rotation_degrees = move_toward(
				$RightSegments.rotation_degrees,
				-90,
				delta*192)
	
	for child in $LeftSegments.get_children():
		var next = child.find_child("Sprite2D",false)
		next.global_position = child.global_position
	for child in $RightSegments.get_children():
		var next = child.find_child("Sprite2D",false)
		next.global_position = child.global_position
	

func Trigger():
	if !trigger:
		trigger = true
		if sfx:
			Global.play_sound2(sfx)
