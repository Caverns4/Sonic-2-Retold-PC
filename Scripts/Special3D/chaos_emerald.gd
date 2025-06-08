@tool
extends Node3D

## Blue is unused.
@export_enum(
"Cyan","Purple","Red","Magenta","Yellow","Green","Silver","Blue") var color: int = 0
@export var jingleTheme: AudioStreamOggVorbis = preload("res://Audio/Soundtrack/s2br_Emeralds.ogg")

var player = null
var collected: bool = false

func _ready() -> void:
	if !Engine.is_editor_hint():
		color = Global.specialStageID
		$Sprite3D.frame = color*4

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		$Sprite3D.frame = color*4
	else:
		if player:
			global_position.z = move_toward(global_position.z,player.global_position.z - 7,delta*60)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if !collected:
		collected = true
		player = body
		Global.music.stop()
		Global.life.stream = jingleTheme
		Global.life.play()
		var value: int = (1 << color)
		Global.emeralds += value
		Global.lastSpecialStageResult = true
		Global.hud.endStage()
