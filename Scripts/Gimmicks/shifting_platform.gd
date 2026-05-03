extends Node2D

@export var sprite: Texture2D = preload("res://Graphics/Gimmicks/SCZ_ShiftingPlatform1.png")
@export var tilt_time: float = 1.0

var target_angle: float = 0.0

@onready var platform: AnimatableBody2D = $ShiftingPlatformChild

func _do_tilt(contact_x: float) -> void:
	var diff: float = sign(contact_x - global_position.x)
	if diff > 0:
		pass
	else:
		pass
