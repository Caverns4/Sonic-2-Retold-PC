extends Node3D

@export var music: AudioStream = preload("res://Audio/Soundtrack/s2br_SpecialStage.ogg")
@export var stage_layouts: Array[PackedScene] = []
## Todo
@onready var stage: SpecialStagePropertiesComponent = $Stage1

var primary_material: StandardMaterial3D = preload("res://Models/SpecialStage/Materials/Color1.tres")
var secondary_material: StandardMaterial3D = preload("res://Models/SpecialStage/Materials/Color2.tres")
var lights_material: StandardMaterial3D = preload("res://Models/SpecialStage/Materials/Lights.tres")

var current_round: int = 0

# was loaded is used for room loading, this can prevent overwriting global information, see Global.gd for more information on scene loading
var wasLoaded = false

func _ready():
	get_tree().paused = false
	# debuging
	if !Global.is_main_loaded:
		return false
	# skip if scene was loaded
	if wasLoaded:
		return false
	
	level_reset_data()
	wasLoaded = true
	
	primary_material.albedo_color = stage.primary_color
	secondary_material.albedo_color = stage.secondary_color
	lights_material.albedo_color = stage.lights_color

	$SpecialHud.ring_requirements = stage.ring_requirements
	$SpecialHud.ring_requirement = stage.ring_requirements[0]
	$SpecialHud.message_state = $SpecialHud.MESSAGES.GET_RINGS

func new_round():
	current_round += 1
	if $SpecialHud:
		$SpecialHud.hud.SetupNextRound(false)

# used for stage starts, also used for returning from special stages
func level_reset_data():
	# music handling
	if SoundDriver.music != null:
		if music != null:
			SoundDriver.music.stream = music
			
			SoundDriver.music.play()
			SoundDriver.music.stream_paused = false
		else:
			SoundDriver.music.stop()
			SoundDriver.music.stream = null

	# set pausing to true
	if Global.main != null:
		Global.main.sceneCanPause = true
