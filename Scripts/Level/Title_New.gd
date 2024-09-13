extends Node2D

@export var music = preload("res://Audio/Soundtrack/s2br_TitleScreen.ogg")
@export var nextZone = load("res://Scene/Zones/ChunkZone.tscn")
@export var testScene = load("res://Scene/Presentation/CharacterSelect.tscn")
var returnScene = load("res://Scene/Presentation/PoweredByWorlds.tscn")
var optionsScene = load("res://Scene/Presentation/OptionsMenu.tscn")

var titleEnd = false
var menuActive = false
var menuEntry = 0
var menuIconYOff = [4,12,20]#[4,20,12]
var particlesDone = false
var menuText = [
	"[color=#FFFF00]1 PLAYER[/color]\n2 PLAYER VS\nOPTIONS",
	"1 PLAYER\n[color=#FFFF00]2 PLAYER VS[/color]\nOPTIONS",
	"1 PLAYER\n2 PLAYER VS\n[color=#FFFF00]OPTIONS[/color]"
]

var scene
var parallaxBackgrounds = [
	"res://Scene/Backgrounds/00-EmeraldHill.tscn",
	"res://Scene/Backgrounds/01-HiddenPalace.tscn",
	"res://Scene/Backgrounds/02-HillTop.tscn",
	"res://Scene/Backgrounds/03-ChemicalPlant.tscn"
]

var paraOffsets = [
	0,
	-216,
	0,
	0,
	0,
]

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
	Global.TwoPlayer = false
	Global.music.stream = music
	Global.music.play()

	var parallax = parallaxBackgrounds[min(Global.savedZoneID,parallaxBackgrounds.size()-1)]
	scene = load(parallax)
	#UpdateMenuDisplay()
	if nextZone != null:
		Global.nextZone = nextZone

func _process(delta):
	if $CanvasLayer/Labels.visible == true and !titleEnd:
		menuActive = true
	
	$TitleBanner.global_position.x += (4*60*delta)
	# animate cogs
	$Celebrations.global_position.x += (4*60*delta)
	
	if !titleEnd:
		CheckCheatInputs()
	
	if $TitleBanner.global_position.x >= 3760 and particlesDone == false:
		$Celebrations.emitting = true
		particlesDone = true
	
	if $TitleBanner.global_position.x >= 4600 and !titleEnd:
		menuActive = false
		titleEnd = true
		Global.main.change_scene_to_file(returnScene,"FadeOut","FadeOut",1)

func _input(event):
	if menuActive and !titleEnd:
		if Input.is_action_just_pressed("gm_down"):
			menuEntry +=1
			$Switch.play()
		if Input.is_action_just_pressed("gm_up"):
			menuEntry -=1
			$Switch.play()
	menuEntry = wrapi(menuEntry,0,3)
	UpdateMenuDisplay()
	
	# end title on start press
	if event.is_action_pressed("gm_pause") and !titleEnd and menuActive:
		if menuEntry !=1:
			MenuOptionChosen()
		
func MenuOptionChosen():
	#if Global.music.get_playback_position() < 14.0:
	#	Global.music.seek(14.0)
	if Global.levelSelectFlag:
		if Input.is_action_pressed("gm_action") and menuEntry == 0:
			menuEntry = 128
		if Input.is_action_pressed("gm_action3"):
			Global.TwoPlayer = true
	
	match menuEntry:
		0:
			titleEnd = true
			Global.main.change_scene_to_file(nextZone,"FadeOut","FadeOut",1)
		1:
			titleEnd = true
			Global.TwoPlayer = true
			Global.PlayerChar1 = Global.CHARACTERS.SONIC
			Global.PlayerChar2 = Global.CHARACTERS.TAILS
			Global.main.change_scene_to_file(testScene,"FadeOut","FadeOut",1)
		2:
			titleEnd = true
			Global.main.change_scene_to_file(optionsScene,"FadeOut","FadeOut",1)
		128:
			titleEnd = true
			Global.main.change_scene_to_file(testScene,"FadeOut","FadeOut",1)
	
func UpdateMenuDisplay():
	$CanvasLayer/Labels/TitleMenu/MenuIcon.position.y = menuIconYOff[menuEntry]
	$CanvasLayer/Labels/TitleMenu/Text.text = menuText[menuEntry]

func CheckCheatInputs():
	var inputs = Input.get_vector("gm_left","gm_right","gm_up","ui_down")
	inputs.x = round(inputs.x)
	inputs.y = round(inputs.y)
	#If this input is the same as previous, do nothing.
	if inputs == lastCheatInput:
		pass
	#If this input is null, rmember it, but don't count it against Cheats
	elif inputs == Vector2.ZERO:
		lastCheatInput = inputs
	#in any othe case, consider this a valid cheat attempt
	else:
		if !Global.levelSelectFlag:
			if inputs == levelSelectCheat[cheatInputCount]:
				cheatInputCount += 1
				print("Correct input!"+ str(inputs))
			else:
				cheatInputCount = 0
				print("Wrong input!" + str(inputs))
			if cheatInputCount == levelSelectCheat.size():
				cheatInputCount = 0
				$TitleBanner/RingChime.play(0.0)
				Global.levelSelectFlag = true
	lastCheatInput = inputs

func InstantiateBG():
	var instance = scene.instantiate()
	instance.scroll_base_offset.y = paraOffsets[min(Global.savedZoneID,parallaxBackgrounds.size()-1)]
	add_child(instance)
	
