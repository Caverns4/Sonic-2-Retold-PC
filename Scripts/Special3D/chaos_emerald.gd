@tool
extends Node3D

## Blue is unused.
@export_enum(
"Cyan","Purple","Red","Magenta","Yellow","Green","Silver","Blue") var color: int = 0
@export var jingleTheme: AudioStreamOggVorbis = preload("res://Audio/Soundtrack/s2br_Emeralds.ogg")

var player = null
var collected: bool = false

@onready var floor_ray = $RayCast3D
@onready var shadow_sprite = $CharacterShadow

func _ready() -> void:
	if !Engine.is_editor_hint():
		color = Global.specialStageID
		$Sprite3D.frame = color*4

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		$Sprite3D.frame = color*4
	else:
		if floor_ray.is_colliding():
			shadow_sprite.global_position = floor_ray.get_collision_point()
			var scale_factor: float = 1.0 - (
			global_position.distance_to(floor_ray.get_collision_point())/10)
			scale_factor = clampf(scale_factor,0.0,1.0)
			shadow_sprite.scale = Vector3(scale_factor,1.0,scale_factor)
		else:
			shadow_sprite.scale = Vector3.ZERO
			
		if player:
			global_position.z = move_toward(global_position.z,player.global_position.z - 7,delta*60)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if !collected:
		collected = true
		player = body
		var success: bool = Global.special_hud.CheckForEmerald(jingleTheme)
		if success:
			Global.lastSpecialStageResult = true
			var value: int = (1 << color)
			Global.emeralds += value
