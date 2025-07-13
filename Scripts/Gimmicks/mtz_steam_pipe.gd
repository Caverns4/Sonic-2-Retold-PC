extends AnimatableBody2D

var Projectile = preload("res://Entities/Hazards/SteamPuff.tscn")
var bullet = null

var origin: Vector2 = Vector2.ZERO
var timer: float = 0.0
var direction: float = 1

func _ready() -> void:
	origin = global_position
