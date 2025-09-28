extends Node

enum ZONES{EMERALD_HILL,HIDDEN_PALACE,HILL_TOP,CHEMICAL_PLANT,
OIL_OCEAN,NEO_GREEN_HILL,METROPOLIS,DUST_HILL,
WOOD_GADGET,CASINO_NIGHT,JEWEL_GROTTO,WINTER,
SAND_SHOWER,TROPICAL,SKY_FORTRESS,DEATH_EGG,
ENDING,SPECIAL_STAGE}

#Two Player Mode flag. Either false or true.
var two_player_mode = false
# player pointers (0 is usually player 1)
var players: Array[Player2D] = []
var special_stage_players: Array = []
# main object reference
var main: MainGameScene = null
# hud object reference
var hud: CanvasLayer = null
# Slot machines (Casino Night Zone Only), probably not needed.
var slotMachines = []
# Character Reel Master
var characterReels: SlotMachineManager = null
# Cheats implimented
var levelSelectFlag = false
var tailsNameCheat = false #if TRUE, Tails will be called "Miles"
var special_exit = ZONES.EMERALD_HILL
var characterSelectMemory = 0
var levelSelctMemory = 0
# checkpoint memory
var checkPoints = []
# reference for the current checkpoint
var currentCheckPoint = -1
var currentCheckPointP2 = -1
# the current level time from when the checkpoint got hit
var checkPointTime = 0
var checkPointTimeP2 = 0
var checkPointRings = 0
var checkPointRingsP2 = 0
# the starting room, this is loaded on game resets, you may want to change this
var startScene = preload("res://Scene/Presentation/Title.tscn")
var nextZone = load("res://Scene/Zones/EmeraldHill1.tscn") # change this to the first level in the game (also set in "reset_values")
# use this to store the current state of the room, changing scene will clear everything
var stageInstanceMemory = null
var stageLoadMemory = null

# score instace for add_score()
var Score = preload("res://Entities/Misc/Score.tscn")
# order for score combo
const SCORE_COMBO = [1,2,3,4,4,4,4,4,4,4,4,4,4,4,4,5]

# timerActive sets if the stage timer should be going
var timerActive = false
var timerActiveP2 = false
var gameOver = false

# stage clear is used to identify the current state of the stage clear sequence
# this is reference in
# res://Scripts/Misc/HUD.gd
# res://Scripts/Objects/GoalPost.gd
var stageClearPhase: int = 0

# characters (if you want more you should add one here, see the player script too for more settings)
enum CHARACTERS {NONE,SONIC,TAILS,KNUCKLES,AMY,MIGHTY,RAY,SONIC_BETA}
var PlayerChar1 = CHARACTERS.SONIC
var PlayerChar2 = CHARACTERS.TAILS
# character name strings, used for "[player] has cleared", this matches the players character ID so you'll want to add the characters name in here matching the ID if you want more characters
var characterNames = ["SONIC","TAILS","KNUCKLES","AMY","MIGHTY","RAY","SONIC"]
#Only used in menus for single player mode.
var playerModes = ["SONIC & TAILS","SONIC","TAILS","KNUCKLES","AMY","MIGHTY","RAY"]
# Gameplay values
var score = 0
var lives = 3
var continues = 0 #Never used
var scoreP2 = 0
var livesP2 = 3
# emeralds use bitwise flag operations, the equivelent for 7 emeralds would be 127
var emeralds = 0
# emerald bit flags
enum EMERALD {
	CYAN=1,
	PURPLE=2,
	RED=4,
	MAGENTA=8,
	YELLOW=16,
	GREEN=32,
	SILVER=64,
	BLUE=128 # Unused
	}
	#RED = 1, BLUE = 2, GREEN = 4, YELLOW = 8, CYAN = 16, SILVER = 32, PURPLE = 64}
## The next special stage to play.
var specialStageID = 0
## Prevoius Special Stage result. true for win.
var lastSpecialStageResult: bool = false
## Saved Ring Count from the special stage.
var special_stage_rings: int = 0
var levelTime = 0 # the timer that counts down while the level isn't completed or in a special ring
var levelTimeP2 = 0
var globalTimer = 0 # global timer, used as reference for animations
var maxTime = 60*10

## If a Boss Fight is currently active.
var fightingBoss = false

#Save Data Atributes
var totalCoins = 0
var unlockFlags = 0
enum UNLOCKS{
	KNUCKLES = 1, # Play as Knuckles: 5 coins
	AMY = 2, # Play as Amy: 10 coins
	MIGHTY = 4, # Play as Mighty: 15 coins
	RAY = 8, # Play as Ray: 20 coins
	BETASONIC = 16, # Beta Sonic Sprites: 20 coins
	BETACASINONIGHT = 32, # Beta Casino Night: 25 coins
	SPEEDCAP = 64, # Disable Air Speed Cap: 25 coins
	ANYCOMBO = 128, # Super Form for all Characters: 30 coins
	SUPEROTHERS = 256, # Allow any player combination: 30 coins
	STARTEMERALDS = 512, # Start with any number of Chaose Emralds: 50 coins
	RINGDRAIN = 1024, # Disable Super Sonic limits: 100 coins
}
var livesMode = true
var airSpeedCap = true
var superRingDrain = true
var superAnyone = false
var anyCharacters = false
var betaCasinoNight = false
var betaSonic = false

# Two Player settings
#Single Race: Pick a character and a zone for each race
#Elimination: Single Race, but no repeat characters per player are allowed.
#Grand Prix: Go through each Zone in Order
enum TWO_PLAYER{SINGLE_RACE,ELIMINATION,GRAND_PRIX}
enum ITEM_MODE{ALL_KINDS_ITEMS,TELEPORT_ONLY,RING_ONLY,EGGMAN_ONLY}
var twoPlayerGameMode = TWO_PLAYER.SINGLE_RACE
var twoPlayerItems = ITEM_MODE.ALL_KINDS_ITEMS

# Arrays per act
# Score,Time,Rings,ScoreP2,TimeP2,RingsP2
var twoPlayActResults = []
var twoPlayActResultsFinal = []

# Array of 0 = no game, 1=player1, 2=player2, 3=draw
# Init to no game
var twoPlayerZoneResults = []

var twoPlayerZones = [
	ZONES.EMERALD_HILL,
	ZONES.CASINO_NIGHT,
	ZONES.CHEMICAL_PLANT,
	ZONES.OIL_OCEAN
]
#Which round the Two Player Mode is in.
var twoPlayerRound = 0

var zoneNames = [
	"Emerald Hill", "Hidden Palace","Hill Top", "Chemical Plant",
	"Oil Ocean", "Neo Green Hill","Metropolis","Dust Hill",
	"Wood Gadget","Casino Night","Jewel Grotto","Winter",
	"Sand Shower","Tropical Sun","Sky Fortress","Death Egg"
]

var savedZoneID = ZONES.EMERALD_HILL # Last played zone. Will mainly be used for the Title Screen.
var savedActID = 0 # selected act ID

# water level of the current level, setting this to null will disable the water
var waterLevel = null
var setWaterLevel = 0 # used by other nodes to change the water level
var waterScrollSpeed = 64 # used by other nodes for how fast to move the water to different levels

# Level settings
var hardBorderLeft   = -100000000
var hardBorderRight  =  100000000
var hardBorderTop    = -100000000
var hardBorderBottom =  100000000
var y_wrap: bool = false

# Animal spawn type reference, see the level script for more information on the types
var animals = [0,1]

# emited when a stage gets started
signal stage_started

# Level memory
# this value contains node paths and can be used for nodes to know if it's been collected from previous playthroughs
# the only way to reset permanent memory is to reset the game, this is used primarily for special stage rings
# Note: make sure you're not naming your level nodes the same thing, it's good practice but if the node's
# share the same paths there can be some overlap and some nodes may not spawn when they're meant to
var nodeMemory = []

# Game settings
var zoomSize = 2
var aspectRatio = 1 #0 for 4:3, 1 for 16x9 (roughly)

var aspectResolutions = [
	Vector2(320,224),
	Vector2(400,224)
	]

var saveFileSelected = 0 #0 = no save

# Hazard type references
enum HAZARDS {NORMAL, FIRE, ELEC, WATER}

# Debugging
var is_main_loaded = false

func _ready():
	# load game data
	load_settings()
	# load Global Save data flags
	var SaveName = "user://Sonic.dat"
	if FileAccess.file_exists(SaveName):
		var save_file = FileAccess.open(SaveName, FileAccess.READ)
		while save_file.get_position() < save_file.get_length():
			var json_string = save_file.get_line()
			# Creates the helper class to interact with JSON.
			var json = JSON.new()
			# Check if there is any error while parsing the JSON string, skip in case of failure.
			var parse_result = json.parse(json_string)
			if !parse_result == OK:
				print("Global Save Data Parse Error!")
				continue
			
			var a = json.data
			if a is Array and a.size() > 0:
				totalCoins = a[0]
				unlockFlags = a[1] 
	else:
		print("Global Save Data does not exist. Skipping.")
	
	# check if main scene is root (prevents crashing if you started from another scene)
	if !(get_tree().current_scene is MainGameScene):
		get_tree().paused = true
		# change scene root to main scene, keep current scene in memory
		var loadNode = get_tree().current_scene.scene_file_path
		var mainScene = load("res://Scene/Main.tscn").instantiate()
		get_tree().root.call_deferred("remove_child",get_tree().current_scene)
		#get_tree().root.current_scene.call_deferred("queue_free")
		get_tree().root.call_deferred("add_child",mainScene)
		mainScene.get_node("SceneLoader").get_child(0).nextScene = load(loadNode)
		await get_tree().process_frame
		get_tree().paused = false
	is_main_loaded = true

func _process(delta):
	# do a check for certain variables, if it's all clear then count the level timer up
	if timerActive and stageClearPhase == 0 and !get_tree().paused:
		levelTime += delta
		
	if timerActiveP2 and !get_tree().paused:
		levelTimeP2 += delta
	# count global timer if game isn't paused
	if !get_tree().paused:
		globalTimer += delta
	
# reset values, self explanatory, put any variables to their defaults in here
func reset_values():
	lives = 3
	livesP2 = 3
	score = 0
	continues = 0
	levelTime = 0
	levelTimeP2 = 0
	#emeralds = 0
	#specialStageID = 0
	checkPoints = []
	checkPointTime = 0
	checkPointTimeP2 = 0
	currentCheckPoint = -1
	currentCheckPointP2 = -1
	animals = [0,1]
	nodeMemory = []
	nextZone = load("res://Scene/Presentation/ZoneLoader.tscn")

# add a score object, see res://Scripts/Misc/Score.gd for reference
func add_score(position: Vector2,value: int,playerID: int):
	var scoreObj = Score.instantiate()
	scoreObj.scoreID = value
	scoreObj.playerID = playerID
	scoreObj.global_position = position
	add_child(scoreObj)

# use a check function to see if a score increase would go above 50,000
func check_score_life(scoreAdd = 0):
	if fmod(score,50000) > fmod(score+scoreAdd,50000):
		SoundDriver.life.stop()
		SoundDriver.life.play()
		lives += 1
		if hud:
			hud.coins += 1
		SoundDriver.music.volume_db = -100

func loadNextLevel():
	#Reset all Checkpoints so the player doesn't respawn in a bad spot
	currentCheckPoint = -1
	currentCheckPointP2 = -1
	maxTime = 60*10
	
	if special_exit > ZONES.EMERALD_HILL:
		savedActID = 0
		savedZoneID = special_exit
		return
	
	savedActID +=1
	if savedActID >= 2:
		match savedZoneID:
			ZONES.EMERALD_HILL:
				savedActID = 0
				savedZoneID = ZONES.NEO_GREEN_HILL
			ZONES.HIDDEN_PALACE:
				savedActID = 0
				savedZoneID = ZONES.OIL_OCEAN
			ZONES.HILL_TOP:
				savedActID = 0
				savedZoneID = ZONES.DUST_HILL
			ZONES.CHEMICAL_PLANT:
				savedActID = 0
				savedZoneID = ZONES.CASINO_NIGHT
			ZONES.OIL_OCEAN:
				savedActID = 0
				savedZoneID = ZONES.METROPOLIS #Demo credits
			ZONES.NEO_GREEN_HILL:
				savedActID = 0
				savedZoneID = ZONES.CHEMICAL_PLANT
			ZONES.METROPOLIS:
				if savedActID > 2:
					savedActID = 0
					savedZoneID = ZONES.ENDING
			ZONES.DUST_HILL:
				savedActID = 0
				savedZoneID = ZONES.OIL_OCEAN
			ZONES.WOOD_GADGET:
				savedActID = 0
				savedZoneID = ZONES.DUST_HILL
			ZONES.CASINO_NIGHT:
				savedActID = 0
				savedZoneID = ZONES.WOOD_GADGET
			ZONES.JEWEL_GROTTO:
				savedActID = 0
				savedZoneID = ZONES.SAND_SHOWER
			ZONES.WINTER:
				savedActID = 0
				savedZoneID = ZONES.EMERALD_HILL
			ZONES.SAND_SHOWER:
				savedActID = 0
				savedZoneID = ZONES.EMERALD_HILL
			ZONES.TROPICAL:
				savedActID = 0
				savedZoneID = ZONES.EMERALD_HILL
			ZONES.SKY_FORTRESS:
				savedActID = 0
				savedZoneID = ZONES.DEATH_EGG
			ZONES.DEATH_EGG:
				savedActID = 0
				savedZoneID = ZONES.ENDING

# Godot doesn't like not having emit signal only done in other nodes so we're using a function to call it
func emit_stage_start():
	emit_signal("stage_started")

# save data settings
func save_settings():
	var file = ConfigFile.new()
	# save settings
	file.set_value("Volume","SFX",AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	file.set_value("Volume","Music",AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	
	file.set_value("Resolution","Zoom",zoomSize)
	file.set_value("Resolution","FullScreen",((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)))
	file.set_value("Resolution","AspectRatio",aspectRatio)
	
	# save config and close
	file.save("user://Settings.cfg")

# load settings
func load_settings():
	var file = ConfigFile.new()
	var err = file.load("user://Settings.cfg")
	if err != OK:
		return false # Return false as an error
	
	if file.has_section_key("Volume","SFX"):
		var sfxVol: float = (file.get_value("Volume","SFX"))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),sfxVol)
		#Set bus mute
		AudioServer.set_bus_mute(
		AudioServer.get_bus_index("SFX"), #channel to mute
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")
		) <= -40.0) #True if < -40.0 
	
	if file.has_section_key("Volume","Music"):
		var musicVol: float = (file.get_value("Volume","Music"))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),musicVol)
		# Mute if needed
		AudioServer.set_bus_mute(
		AudioServer.get_bus_index("Music"), #channel to mute
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")
		) <= -40.0) #True if < -40.0 
	
	if file.has_section_key("Resolution","Zoom"):
		zoomSize = file.get_value("Resolution","Zoom")
		SetupWindowSize()
	
	if file.has_section_key("Resolution","FullScreen"):
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (file.get_value("Resolution","FullScreen")) else Window.MODE_WINDOWED
	
	if file.has_section_key("Resolution","AspectRatio"):
		aspectRatio = file.get_value("Resolution","AspectRatio")
		aspectRatio = 1
		SetupWindowSize()
	

func IsFullScreen():
	if (get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN or 
	get_window().mode == Window.MODE_FULLSCREEN):
		return true
	return false

func SetupWindowSize():
		var window = get_window()
		var resolution = aspectResolutions[aspectRatio]
		window.content_scale_size = Vector2i(resolution.x*2, resolution.y*2)
		var newSize = Vector2i((get_viewport().get_visible_rect().size*zoomSize).round())
		window.set_position(window.get_position()+(window.size-newSize)/2)
		window.set_size(resolution * Global.zoomSize)

func SaveGlobalData():
	var save_file = FileAccess.open("user://Sonic.dat",FileAccess.WRITE)
	var a = [totalCoins,Global.unlockFlags]
	var json_string = JSON.stringify(a)
	save_file.store_line(json_string)
	

func SaveGameData():
	if saveFileSelected == 0:
		return
	var _filename = "Sonic" + str(saveFileSelected) + ".dat"
	var a = Global.Score*(savedZoneID*4)/30+PlayerChar2*PlayerChar1
	print(a)
	
