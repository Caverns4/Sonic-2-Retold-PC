extends Node2D

@export var music = preload("res://Audio/Soundtrack/s2br_TitleScreen.ogg")
## For debug/test builds only.
@export var disable_menu: bool = false
var nextZone = preload("res://Scene/Presentation/ZoneLoader.tscn")
var twoPlayerScene = load("res://Scene/Presentation/TwoPlayerMenu.tscn")
var testScene = load("res://Scene/Presentation/LevelSelect.tscn")
var returnScene = load("res://Scene/Cutscenes/Opening.tscn")
var optionsScene = load("res://Scene/Presentation/OptionsMenu.tscn")

enum STATES{INTRO,WAITING,FADEOUT}
var titleState: int = STATES.INTRO
var titleScroll: bool = false #If the Title Screen should move
var menuActive: bool = false #If the menu is usable

var cheatActive: bool = false #If a cheat code has been applied on this loop, don't allow it to be again

var menuEntry: int = 0
var menuText = [
	"[color=#FFFF00]1 PLAYER[/color]\n2 PLAYER VS\nOPTIONS",
	"1 PLAYER\n[color=#FFFF00]2 PLAYER VS[/color]\nOPTIONS",
	"1 PLAYER\n2 PLAYER VS\n[color=#FFFF00]OPTIONS[/color]"
]
var BackgroundScene
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
	"res://Scene/Backgrounds/14-SkyFortress.tscn",
	"res://Scene/Backgrounds/15-DeathEgg.tscn",
	"res://Scene/Backgrounds/16-Ending.tscn"
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

func _ready():
	#Wipe the player arrays to avoid contamination.
	Global.reset_values()
	#Clear game variables
	Global.two_player_mode = false
	#Prepare the Title Streen Music
	SoundDriver.music.stream = music
	#Prepare the background
	var parallax = parallaxBackgrounds[min(Global.savedZoneID,parallaxBackgrounds.size()-1)]
	BackgroundScene = load(parallax)
	if disable_menu:
		$CanvasLayer/Labels/TitleMenu.queue_free()

func _process(delta):
	if titleScroll:
		$TitleBanner.global_position.x += (4*60*delta)
		$Celebrations.global_position.x += (4*60*delta)
	
	if titleState < STATES.FADEOUT:
		CheckCheatInputs()
	

func _input(event):
	#Update menu if menu is enabled
	if menuActive:
		UpdateMenuDisplay()
	
	# On start button press, skip intro or make selection
	if event.is_action_pressed("gm_pause") and $TitleAnimate.is_playing():
		if !$TitleWaitTimer.is_stopped():
			$TitleAnimate.play("RESET")
			menuActive = true
	elif event.is_action_pressed("gm_pause") and menuActive:
		MenuOptionChosen()

func UpdateMenuDisplay():
	if disable_menu:
		return
	if Input.is_action_just_pressed("gm_down"):
		menuEntry +=1
		$Switch.play()
	if Input.is_action_just_pressed("gm_up"):
		menuEntry -=1
		$Switch.play()
	menuEntry = wrapi(menuEntry,0,3)
	$CanvasLayer/Labels/TitleMenu/MenuIcon.position.y = (menuEntry*8)+4
	$CanvasLayer/Labels/TitleMenu/Text.text = menuText[menuEntry]

func MenuOptionChosen():
	#if Global.music.get_playback_position() < 14.0:
	#	Global.music.seek(14.0)
	if Global.tailsNameCheat:
		#TODO: Make a proper level select code, distinct from the Tails Name Cheat
		if Input.is_action_pressed("gm_action"):
			menuEntry = 128
			Global.levelSelectFlag = true
	
	match menuEntry:
		0:
			Global.savedZoneID = Global.ZONES.EMERALD_HILL
			Global.savedActID = 0
			Global.emeralds = 126
			SetFadeOut(nextZone)
		1:
			Global.two_player_mode = true
			Global.PlayerChar1 = Global.CHARACTERS.SONIC
			Global.PlayerChar2 = Global.CHARACTERS.TAILS
			SetFadeOut(twoPlayerScene)
		2:
			SetFadeOut(optionsScene)
		128:
			SetFadeOut(testScene)

func CheckCheatInputs():
	var inputs = Input.get_vector("gm_left","gm_right","gm_up","ui_down")
	inputs.x = round(inputs.x)
	inputs.y = round(inputs.y)
	#If this input is null, rmember it, but don't count it against Cheats
	if inputs == Vector2.ZERO:
		lastCheatInput = inputs
	#in any othe case, consider this a valid cheat attempt
	elif inputs != lastCheatInput:
		if !cheatActive:
			if inputs == levelSelectCheat[cheatInputCount]:
				cheatInputCount += 1
				print("Correct input!"+ str(inputs))
			else:
				cheatInputCount = 0
				print("Wrong input!" + str(inputs))
			if cheatInputCount == levelSelectCheat.size():
				cheatInputCount = 0
				cheatActive = true
				$TitleBanner/RingChime.play(0.0)
				if !Global.tailsNameCheat:
					Global.tailsNameCheat = true
					Global.characterNames[1] = "MILES"
					Global.playerModes[0] = "SONIC & MILES"
					Global.playerModes[2] = "MILES"
				else:
					Global.tailsNameCheat = false
					Global.characterNames[1] = "TAILS"
					Global.playerModes[0] = "SONIC & TAILS"
					Global.playerModes[2] = "TAILS"
	lastCheatInput = inputs

func InstantiateBG():
	if sceneInstance == null:
		sceneInstance = BackgroundScene.instantiate()
		sceneInstance.scroll_base_offset.y = paraOffsets[min(Global.savedZoneID,parallaxBackgrounds.size()-1)]
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
		Global.main.change_scene_to_file(newScene,"FadeOut","FadeOut",1)

#The sparkling rings have finished, fade out to demo
func _on_celebrations_finished() -> void:
	SetFadeOut(returnScene)
	menuActive = false

#The wait timer has run out, activate the spakls in time with the shooting star sound
func _on_title_wait_timer_timeout() -> void:
	#If and only if a selection has not yet been made
	if menuActive:
		$Celebrations.emitting = true
