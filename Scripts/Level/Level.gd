extends Node2D

@export_enum(
"Emerald Hill", "Hidden Palace","Hill Top", "Chemical Plant",
"Oil Ocean", "Neo Green Hill","Metropolis","Dust Hill",
"Wood Gadget","Casino Night","Jewel Grotto","Winter",
"Sand Shower","Tropical Sun","Sky Fortress","Death Egg") var zoneID = 0
@export var music = preload("res://Audio/Soundtrack/s2br_EmeraldHilll.ogg")
@export var music2P = preload("res://Audio/Soundtrack/s2br_Tropical.ogg")

var nextZone = load("res://Scene/Presentation/ZoneLoader.tscn")

@export_enum("Bird","Squirrel",
"Rabbit", "Chicken",
"Penguin", "Seal",
"Pig", "Eagle",
"Mouse", "Monkey",
"Turtle","Bear",
"Beaver","Fox")var animal1 = 0
@export_enum("Bird", "Squirrel",
"Rabbit", "Chicken",
"Penguin", "Seal",
"Pig", "Eagle",
"Mouse", "Monkey",
"Turtle", "Bear",
"Beaver","Fox")var animal2 = 1

# Boundries
@export var setDefaultLeft = true
@export var defaultLeftBoundry  = 0
@export var setDefaultTop = true
@export var defaultTopBoundry  = 0

@export var setDefaultRight = true
@export var defaultRightBoundry = 16384
@export var setDefaultBottom = true
@export var defaultBottomBoundry = 2048

var twoPlayerWindow = preload("res://Scene/TwoPlayerScreenView.tscn")

# was loaded is used for room loading, this can prevent overwriting global information, see Global.gd for more information on scene loading
var wasLoaded = false

func _ready():
	Global.savedZoneID = zoneID
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
