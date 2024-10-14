extends Node2D


@export var music = preload("res://Audio/Soundtrack/s2br_Options.ogg")
@export var nextZone = load("res://Scene/Presentation/ZoneLoader.tscn")
var selected = false

const LEFT_ROWS = 20 #Including blank rows

# character labels, the amount of labels in here determines the total amount of options, see the set character option at the end for settings
var characterLabels = ["Sonic&Tails", "Sonic", "Tails", "Knuckles", "Amy","Mighty"]
var characterLabelsMiles = ["Sonic&Miles", "Sonic", "Miles", "Knuckles", "Amy","Mighty"]
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
	"                3",
	"Dust Hill       1",
	"                2",
	"",
	"Wood Gadget     1",
	"                2",
	"",
	"Casino Night    1",
	"                2",
	"",
	"Special Stage",
	"",
	"",
	"Player"]
var levelIcons = [ #Use this list to get the number of selectable entries
	Global.ZONES.EMERALD_HILL,
	Global.ZONES.EMERALD_HILL,
	Global.ZONES.HIDDEN_PALACE,
	Global.ZONES.HIDDEN_PALACE,
	Global.ZONES.HILL_TOP,
	Global.ZONES.HILL_TOP,
	Global.ZONES.CHEMICAL_PLANT,
	Global.ZONES.CHEMICAL_PLANT,
	Global.ZONES.OIL_OCEAN,
	Global.ZONES.OIL_OCEAN,
	Global.ZONES.NEO_GREEN_HILL,
	Global.ZONES.NEO_GREEN_HILL,
	Global.ZONES.METROPOLIS,
	Global.ZONES.METROPOLIS,
	Global.ZONES.METROPOLIS,
	Global.ZONES.DUST_HILL,
	Global.ZONES.DUST_HILL,
	Global.ZONES.WOOD_GADGET,
	Global.ZONES.WOOD_GADGET,
	Global.ZONES.CASINO_NIGHT,
	Global.ZONES.CASINO_NIGHT,
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
	characterID = Global.characterSelectMemory
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
			var columnSize = round(LEFT_ROWS/2*1.5)
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
				0: # Emerald Hill Act 1
					Global.savedZoneID = Global.ZONES.EMERALD_HILL
					Global.savedActID = 0
				1: # Emerald Hill Act 2
					Global.savedZoneID = Global.ZONES.EMERALD_HILL
					Global.savedActID = 1
				2: # Hidden Palace 2
					Global.savedZoneID = Global.ZONES.HIDDEN_PALACE
					Global.savedActID = 0
				3: # Hidden Palace 2
					Global.savedZoneID = Global.ZONES.HIDDEN_PALACE
					Global.savedActID = 1
				4: # Hill Top Zone 1
					Global.savedZoneID = Global.ZONES.HILL_TOP
					Global.savedActID = 0
				5: # Hill Top Zone 2
					Global.savedZoneID = Global.ZONES.HILL_TOP
					Global.savedActID = 1
				6: # Chemical Plant 1
					Global.savedZoneID = Global.ZONES.CHEMICAL_PLANT
					Global.savedActID = 0
				7: # Chemical Plant 2
					Global.savedZoneID = Global.ZONES.CHEMICAL_PLANT
					Global.savedActID =1
				8: # Oil Ocean Zone 1
					Global.savedZoneID = Global.ZONES.OIL_OCEAN
					Global.savedActID = 0
				9: # Oil Ocean Zone 2
					Global.savedZoneID = Global.ZONES.OIL_OCEAN
					Global.savedActID = 1
				10: # Neo Green Hill 1
					Global.savedZoneID = Global.ZONES.NEO_GREEN_HILL
					Global.savedActID = 0
				11: # Neo Green Hill 2
					Global.savedZoneID = Global.ZONES.NEO_GREEN_HILL
					Global.savedActID = 1
				12: #Metropolis 1
					Global.savedZoneID = Global.ZONES.METROPOLIS
					Global.savedActID = 0
				13: #Metropolis 2
					Global.savedZoneID = Global.ZONES.METROPOLIS
					Global.savedActID = 1
				14: #Metropolis 3
					Global.savedZoneID = Global.ZONES.METROPOLIS
					Global.savedActID = 2
				15: #Dust Hill 1
					Global.savedZoneID = Global.ZONES.DUST_HILL
					Global.savedActID = 0
				16: #Dust Hill 2
					Global.savedZoneID = Global.ZONES.DUST_HILL
					Global.savedActID = 1
				17: #Wood Gadget 1
					Global.savedZoneID = Global.ZONES.WOOD_GADGET
					Global.savedActID = 0
				18: #Wood Gadget 2
					Global.savedZoneID = Global.ZONES.WOOD_GADGET
					Global.savedActID = 1
				19: #Casino Night 1
					Global.savedZoneID = Global.ZONES.CASINO_NIGHT
					Global.savedActID = 0
				20: #Casino Night 2
					Global.savedZoneID = Global.ZONES.CASINO_NIGHT
					Global.savedActID = 1
				22:
					Global.airSpeedCap = !Global.airSpeedCap
					selected = false
					return
				_: # Invalid Entry
					selected = false
					return
			
			Global.main.change_scene_to_file(Global.nextZone,"FadeOut","FadeOut",1)
			Global.characterSelectMemory = characterID
			
func UpdateCharacterSelect():
	# turn on and off visibility of the characters based on the current selection
	match(characterID):
		0: # Sonic and Tails
			$UI/LabelsRight/CharacterOrigin/Sonic.visible = true
			$UI/LabelsRight/CharacterOrigin/Tails.visible = true
			$UI/LabelsRight/CharacterOrigin/Sonic.position.x = 8
			$UI/LabelsRight/CharacterOrigin/Tails.position.x = -8
			$UI/LabelsRight/CharacterOrigin/Knuckles.visible = false
			$UI/LabelsRight/CharacterOrigin/Amy.visible = false
			$UI/LabelsRight/CharacterOrigin/Mighty.visible = false
		1: # Sonic
			$UI/LabelsRight/CharacterOrigin/Sonic.visible = true
			$UI/LabelsRight/CharacterOrigin/Sonic.position.x = 0
			$UI/LabelsRight/CharacterOrigin/Tails.visible = false
			$UI/LabelsRight/CharacterOrigin/Knuckles.visible = false
			$UI/LabelsRight/CharacterOrigin/Amy.visible = false
			$UI/LabelsRight/CharacterOrigin/Mighty.visible = false
		2: # Tails
			$UI/LabelsRight/CharacterOrigin/Sonic.visible = false
			$UI/LabelsRight/CharacterOrigin/Tails.visible = true
			$UI/LabelsRight/CharacterOrigin/Tails.position.x = 0
			$UI/LabelsRight/CharacterOrigin/Knuckles.visible = false
			$UI/LabelsRight/CharacterOrigin/Amy.visible = false
			$UI/LabelsRight/CharacterOrigin/Mighty.visible = false
		3: # Knuckles
			$UI/LabelsRight/CharacterOrigin/Sonic.visible = false
			$UI/LabelsRight/CharacterOrigin/Tails.visible = false
			$UI/LabelsRight/CharacterOrigin/Knuckles.visible = true
			$UI/LabelsRight/CharacterOrigin/Amy.visible = false
			$UI/LabelsRight/CharacterOrigin/Mighty.visible = false
		4: # Amy
			$UI/LabelsRight/CharacterOrigin/Sonic.visible = false
			$UI/LabelsRight/CharacterOrigin/Tails.visible = false
			$UI/LabelsRight/CharacterOrigin/Knuckles.visible = false
			$UI/LabelsRight/CharacterOrigin/Amy.visible = true
			$UI/LabelsRight/CharacterOrigin/Mighty.visible = false
		5: # Mighty
			$UI/LabelsRight/CharacterOrigin/Sonic.visible = false
			$UI/LabelsRight/CharacterOrigin/Tails.visible = false
			$UI/LabelsRight/CharacterOrigin/Knuckles.visible = false
			$UI/LabelsRight/CharacterOrigin/Amy.visible = false
			$UI/LabelsRight/CharacterOrigin/Mighty.visible = true

func levelSelect_UpdateText(): # levelID
	var j = 0 #Which line to highlight
	var k = 0 #Which label entry to retrieve(In other word, the "real" selection ID
	var textFieldLeft = $UI/Labels/LevelsLeft
	var textFieldRight = $UI/LabelsRight/LevelsRight
	textFieldLeft.text = ""
	textFieldRight.text = ""
	for i in levelLabels.size():
		if i > LEFT_ROWS:
			textFieldLeft = textFieldRight
		if levelLabels[i] != "":
			j +=1
		if j == levelID+1:
			k = j
			if Global.airSpeedCap:
				textFieldLeft.text += "[color=#eeee00]"
			else:
				textFieldLeft.text += "[color=#ee0000]"
			if j == CharacterSelectMenuID:
				
				if !Global.tailsNameCheat:
					textFieldLeft.text += str(characterLabels[characterID]).to_upper() + "[/color]\n"
				else:
					textFieldLeft.text += str(characterLabelsMiles[characterID]).to_upper() + "[/color]\n"
			else:
				textFieldLeft.text += str(levelLabels[i]).to_upper() + "[/color]\n"
		else:
			if j == CharacterSelectMenuID:
				if !Global.tailsNameCheat:
					textFieldLeft.text += str(characterLabels[characterID]).to_upper()
				else:
					textFieldLeft.text += str(characterLabelsMiles[characterID]).to_upper()
			else:
				textFieldLeft.text += str(levelLabels[i]).to_upper() + "\n"
	$UI/LabelsRight/LevelIcon.frame = levelIcons[k-1]
	if levelIcons[k-1] <= Global.ZONES.DEATH_EGG:
		Global.savedZoneID = levelIcons[k-1]
