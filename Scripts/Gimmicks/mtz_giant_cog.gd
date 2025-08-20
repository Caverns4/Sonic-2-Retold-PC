extends Node2D

@export_enum("left","right")var direction = 1
@export var speed: float = 1.0
@export var number_of_teeth: int = 8

var tooth = preload("res://Entities/Gimmicks/mtz_giant_cog_tooth.tscn")

func _ready() -> void:
	direction = direction*2-1

	for i in number_of_teeth-1:
		var child = tooth.instantiate()
		add_child(child)
		child.global_position = global_position
		child.rotation_degrees = 360/number_of_teeth * (i+1)

func _process(delta: float) -> void:
	rotate(deg_to_rad(speed)*direction)
