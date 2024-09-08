@tool
extends StaticBody2D

func _ready():
	if !Engine.is_editor_hint():
		if (get_tree().current_scene is MainGameScene) and !Global.levelSelectFlag:
			visible = false

func _process(delta):
	if Engine.is_editor_hint():
		pass
	
	var size = Vector2(32*scale.x,32*scale.y) 
	$TopLeft.global_position.x = global_position.x - (size.x/2)
	$TopLeft.global_position.y = global_position.y - (size.y/2)
	$TopRight.global_position.x = global_position.x + ((size.x/2)-16)
	$TopRight.global_position.y = global_position.y - (size.y/2)
	$BottomLeft.global_position.x = global_position.x - (size.x/2)
	$BottomLeft.global_position.y = global_position.y + ((size.y/2)-16)
	$BottomRight.global_position.x = global_position.x + ((size.x/2)-16)
	$BottomRight.global_position.y = global_position.y + ((size.y/2)-16)
	
