extends Node2D

## The current Zone ID, for Global.ZONES
@export var zoneID = 0 as Global.ZONES
@export var music = preload("res://Audio/Soundtrack/s2br_EmeraldHilll.ogg")
@export var music2P = preload("res://Audio/Soundtrack/s2br_Tropical.ogg")

var nextZone = load("res://Scene/Presentation/ZoneLoader.tscn")

## Animals dropped from Badniks in this act.
@export_enum("Bird","Squirrel",
"Rabbit", "Chicken",
"Penguin", "Seal",
"Pig", "Eagle",
"Mouse", "Monkey",
"Turtle","Bear",
"Beaver","Fox")var animal1: int = 0
## Animals dropped from Badniks in this act.
@export_enum("Bird", "Squirrel",
"Rabbit", "Chicken",
"Penguin", "Seal",
"Pig", "Eagle",
"Mouse", "Monkey",
"Turtle", "Bear",
"Beaver","Fox")var animal2: int = 1

# Boundries
@export var setDefaultLeft: bool = true
@export var defaultLeftBoundry: int  = 0
@export var setDefaultTop: bool = true
@export var defaultTopBoundry: int  = 0

@export var setDefaultRight: bool = true
@export var defaultRightBoundry: int = 16384
@export var setDefaultBottom: bool = true
@export var defaultBottomBoundry: int = 2048

@export var test = 0 as Global.ZONES

var twoPlayerWindow = preload("res://Scene/TwoPlayerScreenView.tscn")

# was loaded is used for room loading, this can prevent overwriting global information, see Global.gd for more information on scene loading
var wasLoaded = false

func _ready():
	Global.savedZoneID = zoneID as Global.ZONES
	# debuging
	if !Global.is_main_loaded:
		return false
	# skip if scene was loaded
	if wasLoaded:
		return false

	if setDefaultLeft:
		Global.hardBorderLeft  = defaultLeftBoundry
	if setDefaultRight:
		Global.hardBorderRight = defaultRightBoundry
	if setDefaultTop:
		Global.hardBorderTop    = defaultTopBoundry
	if setDefaultBottom:
		Global.hardBorderBottom  = defaultBottomBoundry
	
	level_reset_data(false)
	
	if Global.TwoPlayer == true:
		var twoPlayerScene = twoPlayerWindow.instantiate()
		add_child(twoPlayerScene)
	wasLoaded = true

# used for stage starts, also used for returning from special stages
func level_reset_data(playCard = true):
	Global.stageClearPhase = 0
	Global.fightingBoss = false
	Global.music.stop()
	Global.drowning.stop()
	# music handling
	var levelMusic = null
	if Global.music != null:
		if music != null:
			if !Global.TwoPlayer:
				levelMusic = music
				
			else:
				levelMusic = music2P
			Global.music.stream_paused = false
			Global.themes[Global.THEME.NORMAL] = levelMusic
	Global.playMusic(levelMusic,true)
	Global.playNormalMusic()

	# set next zone
	if nextZone != null:
		Global.nextZone = nextZone
	
	# set pausing to true
	if Global.main != null:
		Global.main.sceneCanPause = true
	# set animals
	Global.animals = [animal1,animal2]
	# if global hud and play card, run hud ready script
	if playCard and is_instance_valid(Global.hud):
		$HUD._ready()
