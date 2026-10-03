@tool
extends Area2D


@export var setWaterLevel: float = 0
@export var setSpeed: float = 512

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _on_SetWaterLevel_body_entered(body: Node2D) -> void:
	# check if entering player is player 1, then set water level
	if body is Player2D:
		if body.playerControl == 1:
			Global.setWaterLevel = global_position.y+setWaterLevel
			Global.waterScrollSpeed = setSpeed

func _draw() -> void:
	# show what the water level is gonna be in the editor
	if Engine.is_editor_hint():
		draw_line(Vector2(-16,setWaterLevel)/scale,Vector2(16,setWaterLevel)/scale,Color(0,0,1,0.5),1+(1/abs(scale.y)))
