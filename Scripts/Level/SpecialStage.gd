extends Node3D

@export var music = preload("res://Audio/Soundtrack/s2br_SpecialStage.ogg")
@export var ringRequirments: Array[int] = [40,80,140]

## Todo
@onready var stage: SpecialStagePropertiesComponent = $Stage1

@export var primary_material: StandardMaterial3D
@export var secondary_material: StandardMaterial3D
@export var lights_material: StandardMaterial3D

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

# used for stage starts, also used for returning from special stages
func level_reset_data():
	# music handling
	if Global.music != null:
		if music != null:
			Global.music.stream = music
			
			Global.music.play()
			Global.music.stream_paused = false
		else:
			Global.music.stop()
			Global.music.stream = null

	# set pausing to true
	if Global.main != null:
		Global.main.sceneCanPause = true
