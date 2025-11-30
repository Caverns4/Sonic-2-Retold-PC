extends Node2D

@export var music = preload("res://Audio/Soundtrack/s2br_Options.ogg")
var title_screen: String = "res://Scene/Presentation/Title.tscn"

@onready var textField = $UI/Labels/OptionsMenu

var selected = false
var menuOption = 0
## Character ids line up with Global.playerModes
var characterID = 0
## Last saved directional input.
var lastInput = Vector2.ZERO

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
# clamp for minimum and maximum sound volume (muted when audio is at lowest)
var clampSounds = [-40.0,6.0]
# how much to iterate through (take the total sum then divide it by how many steps we want)
@onready var soundStep = (abs(clampSounds[0])+abs(clampSounds[1]))/100.0
# button delay
const BUTTON_TIME = 0.3
var stepTimer = 0.2
# screen size limit
var zoomClamp = [1,6]
# Aspect Ratio texts
var aspectClamp = ["4x3","16x9"]
#animation timer for the Character Sprites
var animationTimer = 0.5
var animationframe = 0

func _ready():
	characterID = Global.characterSelectMemory
	SoundDriver.music.stream = music
	SoundDriver.music.play()


func _process(delta: float):
	OptionsMenu_RedrawText()
	if stepTimer > 0.0 and lastInput != Vector2.ZERO:
		stepTimer -= delta
	_unhandledInput(Input)
	
	animationTimer -= delta
	if animationTimer < 0.0:
		animationTimer = 0.5
		animationframe = wrapi(animationframe+1,0,2)
		UpdateCharacterSprites()


func _unhandledInput(event):
	if !selected:
		var inputCue = Input.get_vector("gm_left","gm_right","gm_up","gm_down")
		inputCue.x = round(inputCue.x)
		inputCue.y = round(inputCue.y)
		
		if menuOption == 1 or menuOption == 2:
			if inputCue.x == lastInput.x and stepTimer <= 0:
			# Prepare delay timer for volume update
				stepTimer = 0.05
				lastInput = Vector2.ZERO
			elif inputCue.x != lastInput.x:
				stepTimer = BUTTON_TIME
		
		# set audio busses
		var getBus = "SFX"
		if menuOption > 1:
			getBus = "Music"
		var soundExample = [$Switch,$MenuMusicVolume]
		
		if inputCue != lastInput:
			if inputCue.y > 0:
				stepTimer = BUTTON_TIME
				menuOption = wrapi(menuOption+1,0,optionsText.size())
				$Switch.play()
			if inputCue.y < 0:
				stepTimer = BUTTON_TIME
				menuOption = wrapi(menuOption-1,0,optionsText.size())
				$Switch.play()
			
			match menuOption:
				0: #Character(s)
					if inputCue.x < 0:
						characterID = wrapi(characterID-1,0,Global.playerModes.size()-1)
						$Switch.play()
					elif inputCue.x > 0:
						characterID = wrapi(characterID+1,0,Global.playerModes.size()-1)
						$Switch.play()
					UpdateCharacterSelect()
				1,2: #SFX and Music Volume
					if inputCue.x != 0 and stepTimer > 0:
						soundExample[menuOption-1].play()
						AudioServer.set_bus_volume_db(AudioServer.get_bus_index(getBus
						),clamp(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(getBus)
						)+inputCue.x*soundStep,clampSounds[0],clampSounds[1]))
						AudioServer.set_bus_mute(AudioServer.get_bus_index(getBus
						),AudioServer.get_bus_volume_db(AudioServer.get_bus_index(getBus)
						) <= clampSounds[0])
				3: #Scale
					if (inputCue.x != 0) and !Global.IsFullScreen() and(inputCue != lastInput):
						Global.zoomSize = clamp(Global.zoomSize+inputCue.x,zoomClamp[0],zoomClamp[1])
						Global.SetupWindowSize()
				4: #aspect ratio
					if (inputCue.x > 0):
						Global.aspectRatio = wrapi(Global.aspectRatio+1,0,Global.aspectResolutions.size())
						if !Global.IsFullScreen():
							Global.SetupWindowSize()
						else:
							var resolution = Global.aspectResolutions[Global.aspectRatio]
							get_window().content_scale_size = Vector2i(resolution.x*2, resolution.y*2)
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
				
				4: #Aspecct Ratio
					Global.aspectRatio = wrapi(Global.aspectRatio+1,0,Global.aspectResolutions.size())
					if !Global.IsFullScreen():
						Global.SetupWindowSize()
					else:
						var resolution = Global.aspectResolutions[Global.aspectRatio]
						get_window().content_scale_size = Vector2i(resolution.x*2, resolution.y*2)
				5: # full screen
					get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
				6: # Controls
						Global.save_settings()
						
						var menu = Global.main
						menu = menu.get_child(2).get_child(2) #God this is bad
						print(menu)
						menu.visible = true
						visible = false
						Global.main.wasPaused = false
						get_tree().paused = true
				7: #Back to title
					selected = true
					SetPlayerCharacterIDs()
					Global.save_settings()
					Global.main.change_scene(title_screen)
					Global.characterSelectMemory = characterID


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
		_: # Other
			$UI/Labels/CharacterOrigin/Sonic.visible = true
			$UI/Labels/CharacterOrigin/Sonic.position.x = 0
			$UI/Labels/CharacterOrigin/Tails.visible = false
	UpdateCharacterSprites()

func UpdateCharacterSprites():
	if characterID == 0:
		$UI/Labels/CharacterOrigin/Sonic.frame = animationframe
		$UI/Labels/CharacterOrigin/Tails.frame = 2+animationframe
	else:
		$UI/Labels/CharacterOrigin/Sonic.frame = (characterID-1)*2+animationframe

func SetPlayerCharacterIDs():
	# set player 2 to none to prevent redundant code
	Global.PlayerChar2 = Global.CHARACTERS.NONE
	
	# set the character
	match(characterID):
		0: # Sonic and Tails
			Global.PlayerChar1 = Global.CHARACTERS.SONIC
			Global.PlayerChar2 = Global.CHARACTERS.TAILS
		_: # Sonic
			Global.PlayerChar1 = characterID as Global.CHARACTERS
