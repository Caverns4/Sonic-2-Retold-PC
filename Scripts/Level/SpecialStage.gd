extends Node2D

@export var music = preload("res://Audio/Soundtrack/s2br_SpecialStage.ogg")

# was loaded is used for room loading, this can prevent overwriting global information, see Global.gd for more information on scene loading
var wasLoaded = false

func _ready():
	# debuging
	if !Global.is_main_loaded:
		return false
	# skip if scene was loaded
	if wasLoaded:
		return false
	
	level_reset_data()
	wasLoaded = true
	
	
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
