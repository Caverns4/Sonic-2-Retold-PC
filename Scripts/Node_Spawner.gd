extends Node2D

@export var resource = preload("res://Entities/Items/Ring.tscn")
@export var timeSpan = 4.0

func _process(_delta):
	if get_child_count() <= 0:
		await get_tree().create_timer(timeSpan).timeout
		respawn()

func respawn():
	if get_child_count() == 0:
		var newResource = resource.instantiate()
		add_child(newResource)
