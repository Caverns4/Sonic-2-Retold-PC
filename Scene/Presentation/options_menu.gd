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
# clamp for minimum and maximum sound volume (muted when audio is at lowest)
var clampSounds = [-40.0,6.0]
# how much to iterate through (take the total sum then divide it by how many steps we want)
@onready var soundStep = (abs(clampSounds[0])+abs(clampSounds[1]))/100.0
# button delay
var soundStepDelay = 0
var subSoundStep = 0.2
# screen size limit
var zoomClamp = [1,6]
# Aspect Ratio texts
var aspectClamp = ["4x3","16x9"]

func _ready():
	Global.music.stream = music
	Global.music.play()


func _process(delta: float):
	OptionsMenu_RedrawText()

func _input(event):
	if !selected:
		var inputCue = Input.get_vector("gm_left","gm_right","gm_up","gm_down")
		inputCue.x = round(inputCue.x)
		inputCue.y = round(inputCue.y)
		
		if menuOption == 1 or menuOption == 2:
			if (inputCue.x == 0):
				subSoundStep = 0
				soundStepDelay = 0
			# If input Cue X doesn't = 0 in the options menu
			elif (inputCue.x != 0):
				#Prepare delay timer for volume update
				if inputCue.x != lastInput.x and subSoundStep == 0:
					subSoundStep = 2.0
					soundStepDelay = 0
		# set audio busses
		var getBus = "SFX"
		if menuOption > 1:
			getBus = "Music"
		var soundExample = [$Switch,$MenuMusicVolume]
		
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
				1,2: #SFX and Music Volume
					if soundStepDelay <= 0:
						if inputCue.x != 0:
							soundExample[menuOption-1].play()
							AudioServer.set_bus_volume_db(AudioServer.get_bus_index(getBus
							),clamp(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(getBus)
							)+inputCue.x*soundStep,clampSounds[0],clampSounds[1]))
							AudioServer.set_bus_mute(AudioServer.get_bus_index(getBus
							),AudioServer.get_bus_volume_db(AudioServer.get_bus_index(getBus)
							) <= clampSounds[0])
						soundStepDelay = subSoundStep
					else:
						soundStepDelay -= 0.1
				3: #Scale
					if (inputCue.x != 0) and (
					(get_window().mode != Window.MODE_EXCLUSIVE_FULLSCREEN) and 
					(get_window().mode != Window.MODE_FULLSCREEN)
					)and(inputCue != lastInput):
						Global.zoomSize = clamp(Global.zoomSize+inputCue.x,zoomClamp[0],zoomClamp[1])
						get_window().set_size(get_viewport().get_visible_rect().size*Global.zoomSize)
				4: #aspect ratio
					if (inputCue.x > 0):
						Global.aspectRatio = wrapi(Global.aspectRatio+1,0,Global.aspectResolutions.size())
						var resolution = Global.aspectResolutions[Global.aspectRatio]
						#get_viewport().size = resolution * Global.zoomSize
						get_window().content_scale_size = Vector2i(resolution.x*2, resolution.y*2)
						get_window().set_size(resolution * Global.zoomSize)
						
				5: #full screen
					if (inputCue.x != 0):
						get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
				6: #Controls
					pass
				_: #Back to title
					pass
		lastInput = inputCue
		
		# finish character select if start is pressed
		if (event.is_action_pressed("gm_pause")
		or event.is_action_pressed("gm_action")
		or event.is_action_pressed("gm_action2")
		or event.is_action_pressed("gm_action3")) and !selected:
			match menuOption:
				
				5: # full screen
					get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
				
				7: #Back to title
					selected = true
					SetPlayerCharacterIDs()
					Global.save_settings()
					Global.main.change_scene_to_file(returnScene,"FadeOut","FadeOut",1)


func OptionsMenu_RedrawText():
	textField.text = ""
	
	for i in optionsText.size():
		if menuOption == i:
			textField.text += "[color=#FFFF00]" + optionsText[i].to_upper()
			match i:
				1:
					textField.text += str(round(((AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))-clampSounds[0])/(abs(clampSounds[0])+abs(clampSounds[1])))*100))
				2:
					textField.text += str(round(((AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))-clampSounds[0])/(abs(clampSounds[0])+abs(clampSounds[1])))*100))
				3:
					textField.text += str(Global.zoomSize) + "X"
				4:
					textField.text += str(aspectClamp[Global.aspectRatio])
				5:
					textField.text += onOff[int(((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)))]
			textField.text += "[/color]"
		else:
			textField.text += optionsText[i].to_upper()
			match i:
				1:
					textField.text += str(round(((AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))-clampSounds[0])/(abs(clampSounds[0])+abs(clampSounds[1])))*100))
				2:
					textField.text += str(round(((AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))-clampSounds[0])/(abs(clampSounds[0])+abs(clampSounds[1])))*100))
				3:
					textField.text += str(Global.zoomSize) + "X"
				4:
					textField.text += str(aspectClamp[Global.aspectRatio])
				5:
					textField.text += onOff[int(((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)))]
					

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
