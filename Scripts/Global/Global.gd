extends Node

enum ZONES{EMERALD_HILL,HIDDEN_PALACE,HILL_TOP,CHEMICAL_PLANT,
OIL_OCEAN,NEO_GREEN_HILL,METROPOLIS,DUST_HILL,
WOOD_GADGET,CASINO_NIGHT,JEWEL_GROTTO,WINTER,
SAND_SHOWER,TROPICAL,CYBER_CITY,SKY_FORTRESS,
DEATH_EGG,ENDING,SPECIAL_STAGE}
# Winter Zone is scrapped, I just don't feel like removing all the references.

const save_path = "user://Sonic.dat"
## The Save slot (section in the file). if 0, treat game file as a NO SAVE
var current_save_index: int = 0
## Two Player Mode flag.
var two_player_mode = false
## Player references
var players: Array[Player2D] = []
## Player references in special stages only
var special_stage_players: Array = []
## HUD object reference
var hud: CanvasLayer = null
## HUD object specificiall in special stages.
var special_hud = null
## Slot machines (Casino Night Zone Only), probably not needed.
var slot_machines = []
## Character Reel Master
var character_reels: SlotMachineManager = null


# Menu-related memory
var level_select_flag = false
var tails_name_cheat = false #if true, Tails will be called "Miles"
var character_selection = 0

# checkpoint memory
var checkpoints = []

## Reference for the current checkpoint index for Player 1
var saved_checkpoint: int = -1
## Level time loaded at the Checkpoint
var checkpoint_time_p1: float = 0
## Ring count loaded at the Checkpoint
var checkpoint_rings_p1: int = 0

## Reference for the current checkpoint index for Player 2
var saved_checkpointP2: int = -1
## Level time loaded at the Checkpoint
var checkpoint_time_p2: float = 0
## Ring count loaded at the Checkpoint
var checkpoint_rings_p2: int = 0
## Bonus Stage Stored Data
var bonus_stage_saved_data: Array = []


## Scene when resetting the game
const start_scene: String = "res://Scene/Presentation/Title.tscn"
## the current zone in the queue
var current_zone_pointer: String = "res://Scene/Zones/EmeraldHill1.tscn"
## The next zone in the queue
var next_zone_pointer: String = ""

## MarkObjGone Table, nodes that have been used/collected
var object_table = []

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
# Player Modes in menus
enum PLAYER_MODES {SONIC_AND_TAILS,SONIC,TAILS,KNUCKLES,AMY,MIGHTY,RAY}
#Only used in menus for single player mode.
var playerModes = ["SONIC & TAILS","SONIC","TAILS","KNUCKLES","AMY","MIGHTY","RAY"]
# Gameplay values
var score: int = 0
var lives: int = 3
var continues: int = 0 #Never used
var scoreP2: int = 0
var livesP2: int = 3
# emeralds use bitwise flag operations, the equivelent for 7 emeralds would be 127
var emeralds: int = 63
const ALL_EMERALDS: int = 127
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
var special_stage_id = 0
## Prevoius Special Stage result. true for win.
var special_stage_result: bool = false
## Saved Ring Count from the special stage.
var special_stage_rings: int = 0
var levelTime = 0 # the timer that counts down while the level isn't completed or in a special ring
var levelTimeP2 = 0
var globalTimer = 0 # global timer, used as reference for animations
var maxTime = 60*10

## Strength Tiers used for item destruction. 1 = Mighty's stomp, 2 = Knuckles or Super Sonic
enum STRENGTH_TIER{NORMAL,STRONG,SUPER,UNBREAKABLE}
enum DAMAGE_TYPES{NORMAL,FIRE,ELEC,WATER} 

## If a Boss Fight is currently active.
var fightingBoss: bool = false

#Save Data Atributes
var totalCoins: int = 0
var unlockFlags: int = 0
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
var livesMode:bool = true
var airSpeedCap:bool = true
var superRingDrain:bool = true
var superAnyone:bool = false
var anyCharacters:bool = false
var betaCasinoNight:bool = false
var beta_sonic:bool = false
var insta_shield:bool = true
## If certain debug features will be enabled.
var debug_mode: bool = true: set = _set_debug_mode
func _set_debug_mode(value):
	Main.input_view.visible = value
	debug_mode = value

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
	"Sand Shower","Tropical Sun","Cyber City","Sky Fortress",
	"Death Egg","XXX"
]

## The current played zone. Necessary for Two-Player Mode and the Title Screen.
var saved_zone_id = ZONES.ENDING
var saved_act_id = 0 # selected act ID
var special_exit = ZONES.EMERALD_HILL

# water level of the current level, setting this to null will disable the water
var waterLevel = null
var setWaterLevel = 0 # used by other nodes to change the water level
var waterScrollSpeed = 64 # used by other nodes for how fast to move the water to different levels

# Level settings
var hardBorderLeft: int  = 0
var hardBorderRight: int = 16384
var hardBorderTop: int   = 0
var hardBorderBottom:int = 2048 # Normal max in Sonic 2
## Ideally, this will never be used. Redesign levels as much as possible to avoid it.
var y_wrap: bool = false

# Animal spawn type reference, see the level script for more information on the types
var animals = [0,1]

# emited when a stage gets started
signal stage_started

## Game settings
var zoomSize = 2
## 0 for 4:3, 1 for 16x9 (roughly)
var aspectRatio = 0

var aspectResolutions: Array[Vector2] = [
	Vector2i(320,224),
	Vector2i(400,224)
	]

var crt_resolutions: Array[Vector2] = [
	Vector2i(320,240),
	Vector2i(400,240)
]

# Hazard type references
enum HAZARDS {NORMAL, FIRE, ELEC, WATER}

func _ready():
	# load game data
	load_settings()
	# load Global Save data flags
	var file: ConfigFile = ConfigFile.new()
	var savegame: bool = LoadSaveGameFile(file)
	if !savegame:
		CreateSaveGameFile(file)


func LoadSaveGameFile(file: ConfigFile) -> bool:
	var err := file.load_encrypted_pass(save_path,"SEGA")
	if err != OK:
		DirAccess.remove_absolute(save_path)
		print("Global Save Data Parse Error. Deleted.")
		return false # Return false as an error
	# Parse data
	if file.has_section_key("0","a"):
		totalCoins = (file.get_value("0","a"))
	if file.has_section_key("0","b"):
		unlockFlags = (file.get_value("0","b"))
	#print("Global Save loaded")
	#OS.shell_open(OS.get_user_data_dir())
	return true

func SaveGameFile():
	var file: ConfigFile = ConfigFile.new()
	var err := file.load_encrypted_pass(save_path,"SEGA")
	if err != OK:
		DirAccess.remove_absolute(save_path)
		print("Could not parse save file.")
		return false # Return false as an error
	
	file.set_value("0","a",totalCoins)
	file.set_value("0","b",unlockFlags)
	file.set_value("0","c",(unlockFlags+totalCoins))
	
	var section: String = str(current_save_index)
	if current_save_index:
		file.set_value(section,"a",character_selection)
		file.set_value(section,"b",0)
		file.set_value(section,"c",continues)
		file.set_value(section,"d",saved_zone_id)
		file.set_value(section,"e",emeralds)
		file.set_value(section,"f",lives)
		file.set_value(section,"g",score)
	
	file.save_encrypted_pass(save_path,"SEGA")
	#print(file.get_section_keys(section))

func LoadSaveGameSlotData(index):
	var data: Array = []
	var file: ConfigFile = ConfigFile.new()
	var err := file.load_encrypted_pass(save_path,"SEGA")
	if err != OK:
		print("Could not parse save file.")
		return data
	
	var section: String = str(index)
	if index and file.has_section(section):
		for i in file.get_section_keys(section):
			data.push_back(file.get_value(section,i))
	return data

func CreateSaveGameFile(file: ConfigFile):
	file.set_value("0","a",totalCoins)
	file.set_value("0","b",unlockFlags)
	file.set_value("0","c",(unlockFlags+totalCoins))
	file.save_encrypted_pass(save_path,"SEGA")
	#print("Global Save Data file created.")


func _process(delta):
	# do a check for certain variables, if it's all clear then count the level timer up
	if timerActive and stageClearPhase == 0 and !get_tree().paused:
		levelTime += delta
		
	if timerActiveP2 and !get_tree().paused:
		levelTimeP2 += delta
	# count global timer if game isn't paused
	if !get_tree().paused:
		globalTimer += delta


func reset_level_data():
	Clean_Up_Object_References()
	object_table.clear()
	waterLevel = null
	gameOver = false
	if stageClearPhase != 0:
		saved_checkpoint = -1
		levelTime = 0
		levelTimeP2 = 0
		timerActive = false
		timerActiveP2 = false
	bonus_stage_saved_data.clear()
	globalTimer = 0
	stageClearPhase = 0


## Wipe all data arrays to avoid contamination. This only wipse object references.
func Clean_Up_Object_References():
	hud = null
	special_hud = null
	players.clear()
	special_stage_players.clear()
	checkpoints.clear()
	slot_machines.clear()
	character_reels = null


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
		lives += 1
		if hud:
			hud.coins += 1
		SoundDriver.playExtraLifeMusic()


func getPlayerIDsFromPlayerMode(mode: int = 0):
	# set the character
	match(mode):
		0: # Sonic and Tails
			Global.PlayerChar1 = Global.CHARACTERS.SONIC
			Global.PlayerChar2 = Global.CHARACTERS.TAILS
		_: # Sonic
			Global.PlayerChar1 = mode as Global.CHARACTERS
			Global.PlayerChar2 = Global.CHARACTERS.NONE

func loadNextLevel():
	Global.current_zone_pointer = Global.next_zone_pointer
	
	if special_exit > ZONES.EMERALD_HILL:
		saved_act_id = 0
		saved_zone_id = special_exit
		return
	
	saved_act_id +=1
	if saved_act_id >= 2:
		match saved_zone_id:
			ZONES.EMERALD_HILL:
				saved_act_id = 0
				saved_zone_id = ZONES.HILL_TOP
			ZONES.HIDDEN_PALACE:
				saved_act_id = 0
				saved_zone_id = ZONES.CASINO_NIGHT
			ZONES.HILL_TOP:
				saved_act_id = 0
				saved_zone_id = ZONES.DUST_HILL
			ZONES.CHEMICAL_PLANT:
				saved_act_id = 0
				saved_zone_id = ZONES.CASINO_NIGHT
			ZONES.OIL_OCEAN:
				saved_act_id = 0
				saved_zone_id = ZONES.METROPOLIS
			ZONES.NEO_GREEN_HILL:
				saved_act_id = 0
				saved_zone_id = ZONES.CHEMICAL_PLANT
			ZONES.METROPOLIS:
				saved_act_id = 1 ## Skip Cyber City 1 for now
				saved_zone_id = ZONES.CYBER_CITY
			ZONES.DUST_HILL:
				saved_act_id = 0
				saved_zone_id = ZONES.HIDDEN_PALACE
			ZONES.WOOD_GADGET:
				saved_act_id = 0
				saved_zone_id = ZONES.DUST_HILL
			ZONES.CASINO_NIGHT:
				saved_act_id = 0
				saved_zone_id = ZONES.METROPOLIS
			ZONES.JEWEL_GROTTO:
				saved_act_id = 0
				saved_zone_id = ZONES.SAND_SHOWER
			ZONES.WINTER:
				saved_act_id = 0
				saved_zone_id = ZONES.EMERALD_HILL
			ZONES.SAND_SHOWER:
				saved_act_id = 0
				saved_zone_id = ZONES.OIL_OCEAN
			ZONES.TROPICAL:
				saved_act_id = 0
				saved_zone_id = ZONES.EMERALD_HILL
			ZONES.CYBER_CITY:
				saved_act_id = 0
				saved_zone_id = ZONES.ENDING
			ZONES.SKY_FORTRESS:
				saved_act_id = 0
				saved_zone_id = ZONES.DEATH_EGG
			# Death Egg is a special case.
		if !two_player_mode:
			SaveGameFile()
	Main.change_scene("res://Scene/Presentation/ZoneLoader.tscn")

## Build the respawn array
func save_level_data(pos: Vector2):
	bonus_stage_saved_data.push_back(pos)
	bonus_stage_saved_data.push_back(Global.players[0].rings)
	bonus_stage_saved_data.push_back(levelTime)


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
		SetupWindowSize()
	

func IsFullScreen():
	if (get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN or 
	get_window().mode == Window.MODE_FULLSCREEN):
		return true
	return false

func SetupWindowSize():
		var window = get_window()
		var resolution = aspectResolutions[aspectRatio]
		var crt_res = (crt_resolutions[aspectRatio])*zoomSize*2
		RenderingServer.global_shader_parameter_set("screen_res",crt_res)
		window.content_scale_size = Vector2i(resolution.x, resolution.y)
		var newSize = Vector2i((get_viewport().get_visible_rect().size*zoomSize).round())
		window.set_position(window.get_position()+(window.size-newSize)/2)
		window.set_size(resolution * Global.zoomSize)

func SaveGlobalData():
	var save_file = FileAccess.open("user://Sonic.dat",FileAccess.WRITE)
	var a = [totalCoins,Global.unlockFlags]
	var json_string = JSON.stringify(a)
	save_file.store_line(json_string)
	

func SaveGameData():
	if !current_save_index:
		return false
