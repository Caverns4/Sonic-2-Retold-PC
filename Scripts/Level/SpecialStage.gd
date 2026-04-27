extends Node3D

@export var music: AudioStream = preload("res://Audio/Soundtrack/s2br_SpecialStage.ogg")
@export var stage_layouts: Array[PackedScene] = []
## TODO
@onready var stage: SpecialProperties = $stage_layout/Stage1

var primary_material: StandardMaterial3D = preload("res://Models/SpecialStage/Materials/Color1.tres")
var secondary_material: StandardMaterial3D = preload("res://Models/SpecialStage/Materials/Color2.tres")
var lights_material: StandardMaterial3D = preload("res://Models/SpecialStage/Materials/Lights.tres")

var current_round: int = 0

func _ready() -> void:
	get_tree().paused = false
	stage.queue_free()
	var current_stage: SpecialProperties = stage_layouts[
		min(Global.special_stage_id,stage_layouts.size())].instantiate()
	$stage_layout.add_child(current_stage)
	stage = current_stage
	
	primary_material.albedo_color = stage.primary_color
	secondary_material.albedo_color = stage.secondary_color
	lights_material.albedo_color = stage.lights_color

	$SpecialHud.ring_requirements = stage.ring_requirements
	$SpecialHud.ring_requirement = stage.ring_requirements[0]
	$SpecialHud.message_state = $SpecialHud.MESSAGES.GET_RINGS
	
	SoundDriver.themes[SoundDriver.THEME.NORMAL] = music
	SoundDriver.playMusic(music,true)

func new_round() -> void:
	current_round += 1
	if $SpecialHud:
		$SpecialHud.hud.SetupNextRound(false)
