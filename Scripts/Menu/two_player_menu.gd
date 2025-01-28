extends Node2D

@export var music = preload("res://Audio/Soundtrack/s2br_TitleScreen.ogg")
var nextZone = preload("res://Scene/Presentation/ZoneLoader.tscn")

var sfx_Select = preload("res://Audio/SFX/Gimmicks/Switch.wav")
var sfx_Confirm = preload("res://Audio/SFX/Objects/Checkpoint.wav")

enum MENU_STATE{CHARACTER_SELECT,OPTIONS,ZONE_SELECT,DECIDED}
var state = 0
var timer = 0.0

var selected = false

var p1CharacterSelection: int = 0
var p2CharacterSelection: int = 1
var itemSelection: int = 0
var zoneSelection: int = 0

var playersReady = [false,false]

#Input storage
var inputCue: Vector2 = Vector2.ZERO # Current inputs (this frame)
var lastInput: Vector2 = Vector2.ZERO # Last saved direction input.
var inputCueP2: Vector2 = Vector2.ZERO
var lastInputP2: Vector2 = Vector2.ZERO

# button delay
const BUTTON_TIME = 0.3 # Time to wait before counting repeat inputs.
var stepTimer: float = 0.3

var gameModeStrings = [
	"RACE SELECTION",
	"ELIMINATION MODE",
	"GRAND PRIX",
]

var itemSettingStrings = [
	"ALL KINDS OF ITEMS",
	"TELEPORT ONLY",
	"10RING MONITORS",
	"EGGMAN MONITORS"
]

var characterLabels = ["Sonic", "Tails", "Knuckles"]
var characterLabelsMiles = ["Sonic", "Miles", "Knuckles"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.twoPlayerZoneResults: #If Game is started
		p1CharacterSelection = Global.PlayerChar1-1
		p2CharacterSelection = Global.PlayerChar2-1
		zoneSelection = Global.twoPlayerZones.find(Global.savedZoneID)
	UpdateCharacterFrameInMenu()
	UpdateZoneSelection()


func _physics_process(delta: float) -> void:
	timer+=delta
	#Recieve input
	_unhandledInput(Input)
	
	match state:
		MENU_STATE.CHARACTER_SELECT:
			updateCharacterSelection()
			UpdateCharacterFrameInMenu(delta)
		MENU_STATE.OPTIONS:
			pass
		MENU_STATE.ZONE_SELECT:
			updateZoneSelection()
			UpdateZoneSelection()
	#Remember input
	lastInput = inputCue
	lastInputP2 = inputCueP2
	UpdateCharacterFrameInMenu(delta)
	

func _unhandledInput(event):
	#Player 1
	inputCue = Input.get_vector("gm_left","gm_right","gm_up","gm_down")
	inputCue.x = round(inputCue.x)
	inputCue.y = round(inputCue.y)
	#PLayer 2
	inputCueP2 = Input.get_vector("gm_left_P2","gm_right_P2","gm_up_P2","gm_down_P2")
	inputCueP2.x = round(inputCueP2.x)
	inputCueP2.y = round(inputCueP2.y)

func updateCharacterSelection():
	if inputCue.x !=0 and inputCue.x != lastInput.x and !playersReady[0]:
		p1CharacterSelection += round(inputCue.x)
		p1CharacterSelection = wrapi(p1CharacterSelection,0,characterLabels.size())
	if inputCueP2.x !=0 and inputCueP2.x != lastInputP2.x and !playersReady[1]:
		p2CharacterSelection += round(inputCueP2.x)
		p2CharacterSelection = wrapi(p2CharacterSelection,0,characterLabels.size())
	
	if Input.is_action_just_pressed("gm_super") or Input.is_action_just_pressed("gm_super_P2"):
		itemSelection = wrapi(itemSelection+1,0,itemSettingStrings.size())
		%ItemModeText.text = "[center]using: \n" + str(itemSettingStrings[itemSelection])
	
	if (Input.is_action_just_pressed("gm_action") or
	Input.is_action_just_pressed("gm_pause") and
	!playersReady[0]):
		playersReady[0] = true
		$Control/Player1READY.visible = true
		Global.play_sound2(sfx_Confirm)
		
	if (Input.is_action_just_pressed("gm_action_P2") or
	Input.is_action_just_pressed("gm_pause_P2") and
	!playersReady[1]):
		playersReady[1] = true
		$Control/Player2READY.visible = true
		Global.play_sound2(sfx_Confirm)
		
	if playersReady[0] and playersReady[1]:
		%YButtonIcon.visible = false
		state = MENU_STATE.ZONE_SELECT

func updateZoneSelection():
	if inputCue.y !=0 and inputCue.y != lastInput.y:
		zoneSelection += inputCue.y
		Global.play_sound2(sfx_Select)
	if inputCueP2.y !=0 and inputCueP2.y != lastInputP2.y:
		zoneSelection += inputCueP2.y
		Global.play_sound2(sfx_Select)
	zoneSelection = wrapi(zoneSelection,0,Global.twoPlayerZones.size())
	
	
	if (Input.is_action_just_pressed("gm_action") or
	Input.is_action_just_pressed("gm_pause") or
	Input.is_action_just_pressed("gm_action_P2") or
	Input.is_action_just_pressed("gm_pause_P2")):
		state = MENU_STATE.DECIDED
		Global.PlayerChar1 = p1CharacterSelection+1
		Global.PlayerChar2 = p2CharacterSelection+1
		Global.savedZoneID = Global.twoPlayerZones[zoneSelection]
		Global.savedActID = 0
		Global.twoPlayerItems = itemSelection
		Global.main.change_scene_to_file(nextZone,"FadeOut","FadeOut",1)


func UpdateCharacterFrameInMenu(_delta: float = 0.0):
	var frameX = round(wrapf(timer*2,0.0,1.0))
	%Player1Icon.frame = (p1CharacterSelection*2) + frameX
	%Player2Icon.frame = (p2CharacterSelection*2) + frameX
	if Global.tailsNameCheat:
		%PlayerName1.text = "[center]" + str(characterLabelsMiles[p1CharacterSelection])
		%PlayerName2.text = "[center]" + str(characterLabelsMiles[p2CharacterSelection])
	else:
		%PlayerName1.text = "[center]" + str(characterLabels[p1CharacterSelection])
		%PlayerName2.text = "[center]" + str(characterLabels[p2CharacterSelection])

func UpdateZoneSelection(_delta: float = 0.0):
	%LevelIcon.frame = Global.twoPlayerZones[zoneSelection]
	%"Level Menu".text = ""
	for i in Global.twoPlayerZones.size():
		var zoneName = Global.zoneNames[Global.twoPlayerZones[i]]
		if i == zoneSelection:
			%"Level Menu".text += "[color=EEEE00]" + zoneName + "[/color]\n\n"
		else:
			%"Level Menu".text += zoneName + "\n\n"
