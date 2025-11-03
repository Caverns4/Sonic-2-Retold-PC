extends Node2D

## Height for the Masher to jump.
@export var jumpHeight = 5

func _ready() -> void:
	$Masher.jumpHeight = jumpHeight
