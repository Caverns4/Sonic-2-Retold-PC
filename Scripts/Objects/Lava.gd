@tool
extends "res://Scripts/Objects/Hazard.gd"

@export var size = Vector2(32,32)

func _ready():
	positionIcons()
	if !Engine.is_editor_hint():
		$CollisionShape2D.scale = size/32
		if (get_tree().current_scene is MainGameScene): #and !Global.levelSelectFlag
			$TopLeft.visible = false
			$TopRight.visible = false
			$BottomLeft.visible = false
			$BottomRight.visible = false
		

func _process(delta):
	if Engine.is_editor_hint():
		positionIcons()
	super(delta)

func positionIcons():
	$TopLeft.position.x = 0-(size.x/2)
	$TopLeft.position.y = 0-(size.y/2)
	$TopRight.position.x = (size.x/2)-16
	$TopRight.position.y = 0-(size.y/2)
	
	$BottomLeft.position.x = 0-(size.x/2)
	$BottomRight.position.x = (size.x/2)-16
	$BottomLeft.position.y = (size.y/2)-16
	$BottomRight.position.y = (size.y/2)-16
