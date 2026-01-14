extends Node3D

@export var music: AudioStream = preload("res://Audio/Soundtrack/s2br_SpecialStage.ogg")
@export var stage_layouts: Array[PackedScene] = []
## TODO
@onready var stage: SpecialStagePropertiesComponent = $Stage1

var primary_material: StandardMaterial3D = preload("res://Models/SpecialStage/Materials/Color1.tres")
var secondary_material: StandardMaterial3D = preload("res://Models/SpecialStage/Materials/Color2.tres")
var lights_material: StandardMaterial3D = preload("res://Models/SpecialStage/Materials/Lights.tres")

var current_round: int = 0

func _ready():
	get_tree().paused = false
	primary_material.albedo_color = stage.primary_color
	secondary_material.albedo_color = stage.secondary_color
	lights_material.albedo_color = stage.lights_color

	$SpecialHud.ring_requirements = stage.ring_requirements
	$SpecialHud.ring_requirement = stage.ring_requirements[0]
	$SpecialHud.message_state = $SpecialHud.MESSAGES.GET_RINGS
	
	SoundDriver.themes[SoundDriver.THEME.NORMAL] = music
	SoundDriver.playMusic(music,true)

func new_round():
	current_round += 1
	if $SpecialHud:
		$SpecialHud.hud.SetupNextRound(false)
