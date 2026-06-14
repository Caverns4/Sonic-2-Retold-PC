@tool
extends Node2D

const PLATFORM_SPACING: float = 98

@export var scroll_height: float = 0.0
@export var scroll_speed: int = 1

@onready var platforms: Array[AnimatableBody2D] = [$Platform]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	$Sprite2D.hide()
	var plat: AnimatableBody2D = platforms[0]
	var pos: float = plat.position.y
	for i: int in floori(abs(scroll_height)/PLATFORM_SPACING)-1:
		var next_plat: AnimatableBody2D = plat.duplicate(true)
		pos += PLATFORM_SPACING*sign(scroll_height)
		next_plat.position.y = pos
		add_child(next_plat)
		platforms.append(next_plat)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		$Sprite2D.position.y = scroll_height
		return
	
	for platform in platforms:
		if platform.position.y == scroll_height:
			platform.global_position.y = global_position.y
		else:
			platform.position.y = move_toward(platform.position.y,scroll_height,delta*60*scroll_speed)
		


func animation_complete(platform: AnimatableBody2D,anim_name: String) -> void:
	if anim_name == "Exit":
		platform.global_position.y = global_position.y
