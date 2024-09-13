extends Node2D

@export var music = preload("res://Audio/Soundtrack/s2br_Options.ogg")
var returnScene = load("res://Scene/Presentation/Title.tscn")

@onready var textField = $UI/Control/OptionsMenu

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
var characterLabels = ["Sonic*Tails", "Sonic", "Tails", "Knuckles"]

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
			if inputCue.y < 0:
				menuOption = wrapi(menuOption-1,0,optionsText.size())
			
			match menuOption:
				0: #Character(s)
					pass
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
		if event.is_action_pressed("gm_pause"):
			match menuOption:
				7: #Back to title
					selected = true
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
