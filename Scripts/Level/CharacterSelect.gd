extends Node2D


@export var music = preload("res://Audio/Soundtrack/s2br_Options.ogg")
@export var nextZone = load("res://Scene/Zones/EmeraldHill1.tscn")
var selected = false

const LEFT_ROWS = 14

# character labels, the amount of labels in here determines the total amount of options, see the set character option at the end for settings
var characterLabels = ["Sonic*Tails", "Sonic", "Tails", "Knuckles", "Amy"]
# level labels, the amount of labels in here determines the total amount of options, see set level option at the end for settings
var levelLabels = [ #Every one of these is a line, and some are skipped.
	"Emerald Hill    1",
	"                2",
	"",
	"Hidden Palace   1",
	"                2",
	"",
	"Hill Top        1",
	"                2",
	"",
	"Chemical PLant  1",
	"                2",
	"",
	"Oil Ocean       1",
	"                2",
	"",
	"Neo Green Hill  1",
	"                2",
	"",
	"Metropolis      1",
	"                2",
	"",
	"Special Stage",
	"",
	"",
	"Player"]
var levelIcons = [ #Use this list to get the number of selectable entries
	0,
	0,
	1,
	1,
	2,
	2,
	3,
	3,
	4,
	4,
	5,
	5,
	6,
	6,
	17,
	18
]
# character id lines up with characterLabels
var characterID = 0
# level id lines up with levelLabels
var levelID = 0
var CharacterSelectMenuID = levelIcons.size()

var lastInput = Vector2.ZERO

func _ready():
	Global.music.stream = music
	Global.music.play()
	if nextZone != null:
		Global.nextZone = nextZone

func _process(delta):
		levelSelect_UpdateText()

func _input(event):
	if !selected:
		
		var inputCue = Input.get_vector("gm_left","gm_right","gm_up","gm_down")
		inputCue.x = round(inputCue.x)
		inputCue.y = round(inputCue.y)
		if inputCue != lastInput:
			# select character rotation
			var columnSize = round(LEFT_ROWS/2*1.5)-1
			if inputCue.x < 0:
				if levelID == CharacterSelectMenuID-1:
					characterID = wrapi(characterID-1,0,characterLabels.size())
					$Switch.play()
				else:
					levelID = wrapi(levelID-(columnSize),0,levelIcons.size())
			if  inputCue.x > 0 :
				if levelID == CharacterSelectMenuID-1:
					characterID = wrapi(characterID+1,0,characterLabels.size())
					$Switch.play()
				else:
					if levelID > CharacterSelectMenuID-1 - columnSize and levelID < columnSize:
						levelID = CharacterSelectMenuID-1
					else:
						levelID = wrapi(levelID+(columnSize),0,levelIcons.size())
					

			if inputCue.y > 0:
				levelID = wrapi(levelID+1,0,levelIcons.size())
			if inputCue.y < 0:
				levelID = wrapi(levelID-1,0,levelIcons.size())
		lastInput = inputCue
		
		UpdateCharacterSelect()
		
		# finish character select if start is pressed
		if event.is_action_pressed("gm_pause"):
			selected = true
			# set player 2 to none to prevent redundant code
			Global.PlayerChar2 = Global.CHARACTERS.NONE
			
			# set the character
			match(characterID):
				0: # Sonic and Tails
					Global.PlayerChar1 = Global.CHARACTERS.SONIC
					Global.PlayerChar2 = Global.CHARACTERS.TAILS
				1: # Sonic
					Global.PlayerChar1 = Global.CHARACTERS.SONIC
				2: # Tails
					Global.PlayerChar1 = Global.CHARACTERS.TAILS
				3: # Knuckles
					Global.PlayerChar1 = Global.CHARACTERS.KNUCKLES
				4: # Amy
					Global.PlayerChar1 = Global.CHARACTERS.AMY
				5: # Amy
					Global.PlayerChar1 = Global.CHARACTERS.MIGHTY
			# set the level
			match(levelID):
				0: # Emerald Zone Act 1
					Global.nextZone = load("res://Scene/Zones/EmeraldHill1.tscn")
				1: # Emerald Zone Act 2
					Global.nextZone = load("res://Scene/Zones/EmeraldHill2.tscn")
				2: # Hidden Palace Zone 2
					Global.nextZone = load("res://Scene/Zones/Hidden Palace 1.tscn")
				3: # Hidden Palace Zone 2
					Global.nextZone = load("res://Scene/Zones/Hidden Palace 2.tscn")
				4: # Hill Top Zone 1
					Global.nextZone = load("res://Scene/Zones/HillTop1.tscn")
				5: # Hill Top Zone 2
					Global.nextZone = load("res://Scene/Zones/HillTop2.tscn")
				6: # Chemical Plant Zone 1
					Global.nextZone = load("res://Scene/Zones/ChunkZone.tscn")
				7: # Chemical Plant Zone 2
					Global.nextZone = load("res://Scene/Zones/ChemicalPlant2.tscn")
				8: # Oil Ocean Zone 1
					Global.nextZone = load("res://Scene/Zones/BaseZone.tscn")
				9: # Oil Ocean Zone 2
					Global.nextZone = load("res://Scene/Zones/BaseZoneAct2.tscn")
				10: # Neo Green Hill Zone 1
					Global.nextZone = load("res://Scene/Zones/AquaticRuin1.tscn")
				11: # Neo Green Hill 2
					Global.nextZone = load("res://Scene/Zones/AquaticRuin2.tscn")
				_: # Invalid Entry
					selected = false
					return
			
			Global.main.change_scene_to_file(Global.nextZone,"FadeOut","FadeOut",1)
			
func UpdateCharacterSelect():
	# turn on and off visibility of the characters based on the current selection
	match(characterID):
		0: # Sonic and Tails
			$UI/Labels/CharacterOrigin/Sonic.visible = true
			$UI/Labels/CharacterOrigin/Tails.visible = true
			$UI/Labels/CharacterOrigin/Sonic.position.x = 8
			$UI/Labels/CharacterOrigin/Tails.position.x = -8
			$UI/Labels/CharacterOrigin/Knuckles.visible = false
			$UI/Labels/CharacterOrigin/Amy.visible = false
		1: # Sonic
			$UI/Labels/CharacterOrigin/Sonic.visible = true
			$UI/Labels/CharacterOrigin/Sonic.position.x = 0
			$UI/Labels/CharacterOrigin/Tails.visible = false
			$UI/Labels/CharacterOrigin/Knuckles.visible = false
			$UI/Labels/CharacterOrigin/Amy.visible = false
		2: # Tails
			$UI/Labels/CharacterOrigin/Sonic.visible = false
			$UI/Labels/CharacterOrigin/Tails.visible = true
			$UI/Labels/CharacterOrigin/Tails.position.x = 0
			$UI/Labels/CharacterOrigin/Knuckles.visible = false
			$UI/Labels/CharacterOrigin/Amy.visible = false
		3: # Knuckles
			$UI/Labels/CharacterOrigin/Sonic.visible = false
			$UI/Labels/CharacterOrigin/Tails.visible = false
			$UI/Labels/CharacterOrigin/Knuckles.visible = true
			$UI/Labels/CharacterOrigin/Amy.visible = false
		4: # Amy
			$UI/Labels/CharacterOrigin/Sonic.visible = false
			$UI/Labels/CharacterOrigin/Tails.visible = false
			$UI/Labels/CharacterOrigin/Knuckles.visible = false
			$UI/Labels/CharacterOrigin/Amy.visible = true

func levelSelect_UpdateText(): # levelID
	var j = 0 #Which line to highlight
	var k = 0 #Which label entry to retrieve(In other word, the "real" selection ID
	var textFieldLeft = $UI/Labels/Control/LevelsLeft
	var textFieldRight = $UI/Labels/Control/LevelsRight
	textFieldLeft.text = ""
	textFieldRight.text = ""
	for i in levelLabels.size():
		if i > LEFT_ROWS:
			textFieldLeft = textFieldRight
		if levelLabels[i] != "":
			j +=1
		if j == levelID+1:
			k = j
			if j == CharacterSelectMenuID:
				textFieldLeft.text += "[color=#eeee00]" + str(characterLabels[characterID]).to_upper() + "[/color]\n"
			else:
				textFieldLeft.text += "[color=#eeee00]" + str(levelLabels[i]).to_upper() + "[/color]\n"
		else:
			if j == CharacterSelectMenuID:
				textFieldLeft.text += str(characterLabels[characterID]).to_upper()
			else:
				textFieldLeft.text += str(levelLabels[i]).to_upper() + "\n"
	$UI/LevelIcon.frame = levelIcons[k-1]
