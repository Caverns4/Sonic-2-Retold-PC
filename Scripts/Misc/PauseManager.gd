extends Control

var Text = preload("res://Entities/Misc/PauseMenuText.tscn")

# note: first option in an array is the title, it can't be selected
var menusText = [
# menu 0 (starting menu)
[
" ",
"continue",
"options",
"restart",
"quit",],
# menu 1 (options menu)
[
"options",
"sound 100",
"music 100",
"scale x1",
"full screen off",
"controls",
"back",],
# menu 2 (restart menu confirm)
[
"restart",
"cancel",
"restart",],
# menu 3 (quit game confirm)
[
"quit",
"cancel",
"back to title",],
]

# on or off strings
var onOff = ["off","on"]
# clamp for minimum and maximum sound volume (muted when audio is at lowest)
var clampSounds = [-40.0,6.0]
# how much to iterate through (take the total sum then divide it by how many steps we want)
@onready var soundStep = (abs(clampSounds[0])+abs(clampSounds[1]))/100.0
# button delay
const BUTTON_TIME = 0.3
var stepTimer = BUTTON_TIME
# screen size limit
var zoomClamp = [1,6]

var menu = 0 # current menu option
enum MENUS {MAIN, OPTIONS, RESTART, QUIT}
var option = 0
var lastInput = Vector2.ZERO #Last saved direction input.

func _ready():
	set_menu(menu)


func _process(delta):
	# check if paused and visible, otherwise cancel it out
	if !get_tree().paused or !visible:
		return null
	if stepTimer > 0.0 and lastInput != Vector2.ZERO:
		stepTimer -= delta
	_unhandledInput(Input)

func _input(event):
	# check if paused and visible, otherwise cancel it out
	if !get_tree().paused or !visible:
		return null
	# menu button activate
	if Global.two_player_mode and (
		event.is_action_pressed("gm_pause") or 
		event.is_action_pressed("gm_pause_P2")):
			if Global.main.wasPaused:
				# give frame so game doesn't immedaitely unpause
				await get_tree().process_frame
				Global.main.wasPaused = false
				get_tree().paused = false
				visible = false
				
	# menu button activate
	if (event.is_action_pressed("gm_pause")
	or event.is_action_pressed("gm_action")
	) and !Global.two_player_mode:
		match(menu): # menu handles
			MENUS.MAIN: # main menu
				match(option): # Options
					0: # continue
						if Global.main.wasPaused:
							# give frame so game doesn't immedaitely unpause
							await get_tree().process_frame
							Global.main.wasPaused = false
							get_tree().paused = false
							visible = false
					_: # Set menu to option
						set_menu(option)
			MENUS.OPTIONS: # options menu
				match(option): # Options
					3: # full screen
						get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
						$PauseMenu/VBoxContainer.get_child(option+1).get_child(0).text = update_text(option+1)
					4: # control menu
						Global.save_settings()
						set_menu(0)
						$"../ControllerMenu".visible = true
						visible = false
						Global.main.wasPaused = false
						get_tree().paused = true
					5: # back
						Global.save_settings()
						set_menu(0)
			MENUS.RESTART: # reset level
				match(option): # Options
					0: # cancel
						set_menu(0)
					1: # ok
						set_menu(0)
						Global.main.wasPaused = false
						visible = false
						Global.checkPointTime = 0
						Global.currentCheckPoint = -1
						Global.main.Reload_Level()
						#await Global.main.scene_faded
						Global.main.set_volume(0)
			MENUS.QUIT: # quit option
				match(option): # Options
					0: # cancel
						set_menu(0)
					1: # ok
						visible = false
						set_menu(0)
						Global.main.sceneCanPause = false
						Global.main.reset_game()


func _unhandledInput(_event):
	#Ignore menu in 2-Player mode so player's can't grief eachother.
	if Global.two_player_mode:
		return
	
	# check if paused and visible, otherwise cancel it out
	if !get_tree().paused or !visible:
		return
	#Get input vector, round to -1, 0, or 1
	var inputCue = Input.get_vector("gm_left","gm_right","gm_up","gm_down")
	inputCue.x = round(inputCue.x)
	inputCue.y = round(inputCue.y)
	#var inputCueP2: Vector2 = Vector2.ZERO
	
	# change up/down menu options
	if inputCue.y > 0 and inputCue.y != lastInput.y:
		choose_option(option+1)
		stepTimer = BUTTON_TIME
	elif inputCue.y < 0 and inputCue.y != lastInput.y:
		choose_option(option-1)
		stepTimer = BUTTON_TIME
	
	if (inputCue.x == 0) or inputCue.x != lastInput.x:
		stepTimer = BUTTON_TIME
	
	# If input Cue X doesn't = 0 in the options menu
	if (inputCue.x != 0) and menu == MENUS.OPTIONS:
		
		#Prepare delay timer for volume update
		if inputCue.x == lastInput.x and stepTimer <= 0 and option < 2:
		# Prepare delay timer for volume update
			stepTimer = 0.05
			lastInput = Vector2.ZERO
		elif inputCue.x != lastInput.x:
			stepTimer = BUTTON_TIME
		
		if inputCue == lastInput:
			return
		
		# set audio busses
		var getBus = "SFX"
		if option > 0:
			getBus = "Music"
		var soundExample = [$MenuVert,$MenuMusicVolume]
		
		match(option):
			0, 1: # Volume
					#Play sample audio
					soundExample[option].play()
					#Set stream volume
					AudioServer.set_bus_volume_db(
					AudioServer.get_bus_index(getBus), #arg 1
					clamp(AudioServer.get_bus_volume_db(
					AudioServer.get_bus_index(getBus))+inputCue.x*soundStep,
					clampSounds[0], #Clamp Low Value
					clampSounds[1])) #Clamp High Value
					#Mute if needed
					AudioServer.set_bus_mute( #Set bus mute
					AudioServer.get_bus_index(getBus), #channel to mute
					AudioServer.get_bus_volume_db(AudioServer.get_bus_index(getBus)
					) <= clampSounds[0]) #True if < -40.0 
					
			2: # Scale
				if (inputCue.x != 0) and (
				(get_window().mode != Window.MODE_EXCLUSIVE_FULLSCREEN) and 
				(get_window().mode != Window.MODE_FULLSCREEN)
				)and(inputCue != lastInput):
					Global.zoomSize = clamp(Global.zoomSize+inputCue.x,zoomClamp[0],zoomClamp[1])
					get_window().set_size(get_viewport().get_visible_rect().size*Global.zoomSize)
		
		$PauseMenu/VBoxContainer.get_child(option+1).get_child(0).text = update_text(option+1)
	lastInput = inputCue
	

func choose_option(optionSet = option+1, playSound = true):
	# reset curren option colour to white
	$PauseMenu/VBoxContainer.get_child(option+1).modulate = Color.WHITE
	# change to new option, set the new option colour to yellow
	option = wrapi(optionSet,0,menusText[menu].size()-1)
	$PauseMenu/VBoxContainer.get_child(option+1).modulate = Color(1,1,0)
	
	if playSound:
		$MenuVert.play()

func set_menu(menuID = 0):
	# clear all current text nodes
	for i in $PauseMenu/VBoxContainer.get_children():
		i.queue_free()
	# set new menu
	menu = menuID
	
	# loop through menu lists and create a text node for each option
	for i in menusText[menuID].size():
		var text = Text.instantiate()
		$PauseMenu/VBoxContainer.add_child(text)
		var getText = text.get_child(0)
		if menuID != 1:
			getText.text = menusText[menuID][i]
		else: # options menu settings
			getText.text = update_text(i)
		if i == 0: # set title option to red
			text.modulate = Color(1,0,0)
		if i == 1: # set default option to yellow
			text.modulate = Color(1,1,0)
	# reset option (prevents going beyond the current option list)
	choose_option(0,false)


# updates for the option menu texts
func update_text(textRow = 0):
	match(textRow):
		1: # Sound
			return "sound "+str(int(((AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))-clampSounds[0])/(abs(clampSounds[0])+abs(clampSounds[1])))*100))
		2: # Music
			return "music "+str(int(((AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))-clampSounds[0])/(abs(clampSounds[0])+abs(clampSounds[1])))*100))
		3: # Scale
			return "scale x"+str(Global.zoomSize)
		4: # Full screen
			return "full screen "+onOff[int(((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)))]
		_: # Default
			return menusText[menu][textRow]


func _on_visibility_changed() -> void:
	if visible:
		var img = get_viewport().get_texture().get_image()
		var tex = ImageTexture.create_from_image(img)
		$PauseCover.texture = tex
		$PauseCover.size = tex.get_size()
	
	if Global.two_player_mode:
		$PauseMenu.visible = false
	else:
		$PauseMenu.visible = true
