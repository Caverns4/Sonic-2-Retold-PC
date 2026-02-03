extends Node2D

@export var music = preload("res://Audio/Soundtrack/s2br_TitleScreen.ogg")
@onready var title_menu: VBoxContainer = $CanvasLayer/Menu
var zone_loader: String = "res://Scene/Presentation/DataSelectMenu.tscn"
var two_player_menu: String = "res://Scene/Presentation/TwoPlayerMenu.tscn"
var level_select_menu: String = "res://Scene/Presentation/LevelSelect.tscn"
var opening_cutscene: String = "res://Scene/Cutscenes/Opening.tscn"
var optionsScene: String = "res://Scene/Presentation/OptionsMenu.tscn"

enum STATES{INTRO,WAITING,FADEOUT}
var titleState: int = STATES.INTRO
## If the Title Screen should be moving
var titleScroll: bool = false

## Toggle when the menu should display.
var menuActive: bool = false:
	set(value):
		menuActive = value
		if value:
			title_menu.show()
			await get_tree().create_timer(0.5).timeout
			title_menu.get_child(0).grab_focus()

## If a cheat code has been applied on this loop, don't allow it to be again
var cheatActive: bool = false

var delete_me: int = 0

var BackgroundScene: PackedScene
var parallaxBackgrounds = [
	"res://Scene/Backgrounds/00-EmeraldHill.tscn",
	"res://Scene/Backgrounds/01-HiddenPalace.tscn",
	"res://Scene/Backgrounds/02-HillTop.tscn",
	"res://Scene/Backgrounds/03-ChemicalPlant.tscn",
	"res://Scene/Backgrounds/04-OilOcean.tscn",
	"res://Scene/Backgrounds/05-NeoGreenHill.tscn",
	"res://Scene/Backgrounds/06-Metropolis.tscn",
	"res://Scene/Backgrounds/07-DustHill.tscn",
	"res://Scene/Backgrounds/08-WoodGadget.tscn",
	"res://Scene/Backgrounds/09-CasinoNightF.tscn",
	"res://Scene/Backgrounds/10-JewelGrotto.tscn",
	"res://Scene/Backgrounds/11-WinterHill.tscn",
	"res://Scene/Backgrounds/12-SandShower.tscn",
	"res://Scene/Backgrounds/13-TropicalJungle.tscn",
	"res://Scene/Backgrounds/14-CyberCity.tscn",
	"res://Scene/Backgrounds/15-SkyFortress.tscn",
	"res://Scene/Backgrounds/16-DeathEgg.tscn",
	"res://Scene/Backgrounds/17-Ending.tscn",
]
var sceneInstance = null

var paraOffsets = [
	0,
	-216,
	0,
	0,
	-256,
	-256,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
]

#Cheat Code Inputs
var levelSelectCheat = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.DOWN,
	Vector2.DOWN,
	Vector2.UP
]
var cheatInputCount = 0 #Correct inputs
var lastCheatInput = Vector2.ZERO
## Last saved directional input.
var lastInput = Vector2.ZERO

func _ready():
	title_menu.hide()
	get_tree().paused = false
	#Wipe the player arrays to avoid contamination.
	reset_values()
	#Prepare the Title Streen Music
	SoundDriver.music.stream = music
	#Prepare the background
	var parallax = parallaxBackgrounds[min(Global.saved_zone_id,parallaxBackgrounds.size()-1)]
	BackgroundScene = load(parallax)

func _process(delta):
	if titleScroll:
		$TitleBanner.global_position.x += (5*60*delta)
		$Celebrations.global_position.x += (5*60*delta)
	if titleState < STATES.FADEOUT:
		_unhandledInput(Input)

func _unhandledInput(_event):
	var inputCue = Input.get_vector("gm_left","gm_right","gm_up","gm_down")
	inputCue.x = round(inputCue.x)
	inputCue.y = round(inputCue.y)
	
	#if menuActive:
	#	UpdateMenuDisplay(inputCue)
	CheckCheatInputs(inputCue)
	lastInput = inputCue

func _input(event):
	# On start button press, skip intro or make selection
	if event.is_action_pressed("gm_pause") and $TitleAnimate.is_playing():
		if !$TitleWaitTimer.is_stopped():
			$TitleAnimate.play("RESET")
			menuActive = true
	#elif event.is_action_pressed("gm_pause") and menuActive:
	#	MenuOptionChosen()

func MenuOptionChosen():
	if Global.level_select_flag:
		#TODO: Make a proper level select code, distinct from the Tails Name Cheat
		if Input.is_action_pressed("gm_action"):
			delete_me = 128
	
	match delete_me:
		0:
			Global.saved_zone_id = Global.ZONES.EMERALD_HILL
			Global.saved_act_id = 0
			Global.emeralds = 126
			SetFadeOut(zone_loader)
		1:
			Global.two_player_mode = true
			Global.PlayerChar1 = Global.CHARACTERS.SONIC
			Global.PlayerChar2 = Global.CHARACTERS.TAILS
			SetFadeOut(two_player_menu)
		2:
			SetFadeOut(optionsScene)
		_:
			SetFadeOut(level_select_menu)

func CheckCheatInputs(inputCue: Vector2 = Vector2.ZERO):
	if inputCue != lastCheatInput and inputCue:
		if !cheatActive:
			if inputCue == levelSelectCheat[cheatInputCount]:
				cheatInputCount += 1
				#print("Correct input!"+ str(inputCue))
			else:
				cheatInputCount = 0
				#print("Wrong input!" + str(inputCue))
			if cheatInputCount == levelSelectCheat.size():
				cheatInputCount = 0
				cheatActive = true
				Global.level_select_flag = true
				Global.debug_mode = true
				$TitleBanner/RingChime.play(0.0)
				if !Global.tails_name_cheat:
					Global.tails_name_cheat = true
					Global.characterNames[1] = "MILES"
					Global.playerModes[0] = "SONIC & MILES"
					Global.playerModes[2] = "MILES"
				else:
					Global.tails_name_cheat = false
					Global.characterNames[1] = "TAILS"
					Global.playerModes[0] = "SONIC & TAILS"
					Global.playerModes[2] = "TAILS"
	lastCheatInput = inputCue

func InstantiateBG():
	if sceneInstance == null:
		sceneInstance = BackgroundScene.instantiate()
		sceneInstance.scroll_base_offset.y = paraOffsets[min(Global.saved_zone_id,parallaxBackgrounds.size()-1)]
		add_child(sceneInstance)
	#Activate the Menu
	menuActive = true

func PlayMusic():
	SoundDriver.music.play()
	titleScroll = true #Begin scrolling
	$TitleWaitTimer.start()

func SetFadeOut(newScene):
	if titleState < STATES.FADEOUT:
		titleState = STATES.FADEOUT
		menuActive = false
		Main.change_scene(newScene,"FadeOut",1.0,false)

#The sparkling rings have finished, fade out to demo
func _on_celebrations_finished() -> void:
	menuActive = false
	SetFadeOut(opening_cutscene)

#The wait timer has run out, activate the spakls in time with the shooting star sound
func _on_title_wait_timer_timeout() -> void:
	#If and only if a selection has not yet been made
	if menuActive:
		$Celebrations.emitting = true

func reset_values():
	Global.stageClearPhase = 1
	Global.reset_level_data()
	Global.two_player_mode = false
	Global.score = 0
	Global.scoreP2 = 0
	Global.levelTime = 0
	Global.levelTimeP2 = 0
	Global.lives = 3
	Global.livesP2 = 3
	Global.twoPlayerZoneResults.clear()
	Global.twoPlayActResults.clear()
	Global.twoPlayerRound = 0
	Global.continues = 0
	#Global.emeralds = 0
	#Global.special_stage_id = 0
	Global.checkpoint_time_p1 = 0
	Global.checkpoint_time_p2 = 0
	Global.saved_checkpoint = -1
	Global.saved_checkpointP2 = -1
	Global.animals = [0,1]


func _on_player_pressed() -> void:
	Global.saved_zone_id = Global.ZONES.EMERALD_HILL
	Global.saved_act_id = 0
	Global.emeralds = 126
	SetFadeOut(zone_loader)


func _on_player_vs_pressed() -> void:
	Global.two_player_mode = true
	Global.PlayerChar1 = Global.CHARACTERS.SONIC
	Global.PlayerChar2 = Global.CHARACTERS.TAILS
	SetFadeOut(two_player_menu)


func _on_options_pressed() -> void:
	SetFadeOut(optionsScene)


func _on_quit_pressed() -> void:
	## TODO: Make a fadeout
	titleState = STATES.FADEOUT
	menuActive = false
	Main.quit_game()
