extends Node2D

## Height for the Masher to jump.
@export var jumpHeight: float = 5.0

func _ready() -> void:
	$Masher.jumpHeight = jumpHeight
