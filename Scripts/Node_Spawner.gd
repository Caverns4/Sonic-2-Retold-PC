extends Node2D

@export var resource = preload("res://Entities/Items/Ring.tscn")
@onready var isOnScreen = $VisibleOnScreenNotifier2D

func _ready() -> void:
	isOnScreen.visible = true

func _process(_delta):
	if get_child_count() <= 1 and !isOnScreen.is_on_screen():
		#await get_tree().create_timer(timeSpan).timeout
		var newResource = resource.instantiate()
		add_child(newResource)
