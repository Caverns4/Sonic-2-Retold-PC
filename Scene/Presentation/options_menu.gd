extends Node2D

@export var music = preload("res://Audio/Soundtrack/s2br_Options.ogg")
var returnScene = load("res://Scene/Presentation/Title.tscn")

@onready var textField = $UI/Labels/OptionsMenu

var selected = false
var menuOption = 0
# character id lines up with characterLabels
var characterID = 0
var lastInput = Vector2.ZERO #Last saved direction input.

var optionsText = [
"player select",
"sound volume ",
"music volume ",
"scale        ",
"aspect ratio ",
"full screen  ",
"set controls",
"title screen"]

# on or off strings
var onOff = ["off","on"]
var characterLabels = ["Sonic&Tails", "Sonic", "Tails", "Knuckles"]

func _ready():
	pass

func _process(delta: float):
	OptionsMenu_RedrawText()

func _input(event):
	if !selected:
		var inputCue = Input.get_vector("gm_left","gm_right","gm_up","gm_down")
		inputCue.x = round(inputCue.x)
		inputCue.y = round(inputCue.y)
		if inputCue != lastInput:
			
			if inputCue.y > 0:
				menuOption = wrapi(menuOption+1,0,optionsText.size())
				$Switch.play()
			if inputCue.y < 0:
				menuOption = wrapi(menuOption-1,0,optionsText.size())
				$Switch.play()
			
			match menuOption:
				0: #Character(s)
					if inputCue.x < 0:
						characterID = wrapi(characterID-1,0,characterLabels.size())
						$Switch.play()
					elif inputCue.x > 0:
						characterID = wrapi(characterID+1,0,characterLabels.size())
						$Switch.play()
					UpdateCharacterSelect()
				1: #SFX Volume
					pass
				2: #Music Volume
					pass
				3: #Scale
					pass
				4: #aspect ratio
					pass
				5: #full screen
					pass
				6: #Controls
					pass
				_: #Back to title
					pass
		lastInput = inputCue
		
		# finish character select if start is pressed
		if event.is_action_pressed("gm_pause") and !selected:
			match menuOption:
				7: #Back to title
					selected = true
					SetPlayerCharacterIDs()
					Global.main.change_scene_to_file(returnScene,"FadeOut","FadeOut",1)


func OptionsMenu_RedrawText():
	textField.text = ""
	
	for i in optionsText.size():
		if menuOption == i:
			textField.text += "[color=#FFFF00]" + optionsText[i].to_upper()
			
			textField.text += "[/color]"
		else:
			textField.text += optionsText[i].to_upper()

		textField.text += "\n\n"


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

func SetPlayerCharacterIDs():
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
		5: # Mighty
			Global.PlayerChar1 = Global.CHARACTERS.MIGHTY
