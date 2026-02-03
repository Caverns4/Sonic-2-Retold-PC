extends Control

@export var music = preload("res://Audio/Soundtrack/s2br_Options.ogg")
var title_screen: String = "res://Scene/Presentation/Title.tscn"

var slider_menu_scene: PackedScene = preload("res://Entities/MenuObjects/slider_popup_menu.tscn")

@onready var menu_text: VBoxContainer = $Menu
@onready var sfx_volume_button: Button = $Menu/SFXVolumeButton
@onready var music_volume_button: Button = $Menu/MusicVolumeButton
@onready var crt_filter_button: Button = $Menu/CRTFilterButton
@onready var aspect_ratio_button: Button = $Menu/AspectRatioButton
@onready var scale_button: Button = $Menu/ScaleButton
@onready var full_screen_button: Button = $Menu/FullscreenButton
@onready var control_button: Button = $Menu/ControlsButton
@onready var quit_button: Button = $Menu/BackToTitleButton
var controls_locked: bool = false :
	set(value):
		controls_locked = value
		if value:
			menu_text.process_mode = Node.PROCESS_MODE_DISABLED
			menu_text.hide()
		else:
			menu_text.process_mode = Node.PROCESS_MODE_PAUSABLE
			menu_text.show()

var selected = false
var menuOption = 1
## Last saved directional input.
var lastInput = Vector2.ZERO

## clamp for minimum and maximum sound volume
var clampSounds = [-40.0,6.0]
## how much to iterate through (take the total sum then divide it by how many steps we want)
@onready var soundStep = (abs(clampSounds[0])+abs(clampSounds[1]))/100.0
# button delay
const BUTTON_TIME = 0.3
var stepTimer = 0.2
# screen size limit
var zoomClamp = [1,6]
#animation timer for the Character Sprites
var animationTimer = 0.5
var animationframe = 0

func _ready():
	SoundDriver.music.stream = music
	SoundDriver.music.play()
	
	crt_filter_button.text = "Crt Filter:      " + Global.on_off[int(Main.crt_filter.visible)]
	aspect_ratio_button.text = "Aspect Ratio:    " + Global.aspect_strings[int(Global.aspectRatio)]
	scale_button.text = "scale:" + (str(int(Global.zoomSize))+"x")
	var onoff: String = Global.on_off[int(((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)))]
	full_screen_button.text = "Full Screen: " + onoff
	
	await get_tree().create_timer(0.5).timeout
	$Menu/SFXVolumeButton.grab_focus()


func _process(delta: float):
	animationTimer -= delta
	if animationTimer < 0.0:
		animationTimer = 0.5
		animationframe = wrapi(animationframe+1,0,2)
		UpdateCharacterSprites()


## TODO
func UpdateCharacterSprites():
#	$UI/Labels/CharacterOrigin/Sonic.frame = animationframe
#	$UI/Labels/CharacterOrigin/Tails.frame = 2+animationframe
	pass

func _on_sfx_volume_button_pressed() -> void:
	controls_locked = true
	var volume_to_int = int(((AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))-clampSounds[0])/(abs(clampSounds[0])+abs(clampSounds[1])))*100)
	var sfx_menu: SliderPopUpMenu = slider_menu_scene.instantiate()
	sfx_menu.initial_value = volume_to_int
	sfx_menu.sound_effect = $MenuSfxVolume
	sfx_menu.title = "SFX Volume: "
	add_child(sfx_menu)
	var new_volume = await sfx_menu.menu_exit
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),
	clamp(clampSounds[0]+(new_volume*soundStep),
	clampSounds[0],clampSounds[1]))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"),
	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")
	) <= clampSounds[0])
	controls_locked = false
	sfx_volume_button.grab_focus()

func _on_music_volume_button_pressed() -> void:
	controls_locked = true
	var volume_to_int = int(((AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))-clampSounds[0])/(abs(clampSounds[0])+abs(clampSounds[1])))*100)
	var sfx_menu: SliderPopUpMenu = slider_menu_scene.instantiate()
	sfx_menu.initial_value = volume_to_int
	sfx_menu.sound_effect = $MenuMusicVolume
	sfx_menu.title = "Music Volume:"
	add_child(sfx_menu)
	var new_volume = await sfx_menu.menu_exit
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),
	clamp(clampSounds[0]+(new_volume*soundStep),
	clampSounds[0],clampSounds[1]))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"),
	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")
	) <= clampSounds[0])
	controls_locked = false
	music_volume_button.grab_focus()


func _on_crt_filter_button_pressed() -> void:
	Main.crt_filter.visible = !Main.crt_filter.visible
	crt_filter_button.text = "Crt Filter:      " + Global.on_off[int(Main.crt_filter.visible)]


func _on_aspect_ratio_button_pressed() -> void:
	Global.aspectRatio = wrapi(Global.aspectRatio+1,0,Global.aspectResolutions.size())
	if !Global.IsFullScreen():
		Global.SetupWindowSize()
	else:
		var resolution = Global.aspectResolutions[Global.aspectRatio]
		get_window().content_scale_size = Vector2i(resolution.x*2, resolution.y*2)
	aspect_ratio_button.text = "Aspect Ratio:    " + Global.aspect_strings[int(Global.aspectRatio)]


func _on_scale_button_pressed() -> void:
	controls_locked = true
	var sfx_menu: SliderPopUpMenu = slider_menu_scene.instantiate()
	sfx_menu.initial_value = Global.zoomSize-1
	sfx_menu.max_slider_value = 5
	sfx_menu.title = "Scale:"
	add_child(sfx_menu)
	var new_scale = await sfx_menu.menu_exit
	Global.zoomSize = new_scale+1
	if (
		(get_window().mode != Window.MODE_EXCLUSIVE_FULLSCREEN) and 
		(get_window().mode != Window.MODE_FULLSCREEN)):
			get_window().set_size(get_viewport().get_visible_rect().size*Global.zoomSize)
	controls_locked = false
	scale_button.text = "scale:" + (str(int(Global.zoomSize))+"x")
	scale_button.grab_focus()



func _on_fullscreen_button_pressed() -> void:
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
	var onoff: String = Global.on_off[int(((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)))]
	full_screen_button.text = "Full Screen: " + onoff


func _on_controls_button_pressed() -> void:
	Global.save_settings()
	controls_locked = true
	menu_text.hide()
	Main.control_menu.visible = true
	get_tree().paused = true
	
	controls_locked = false
	menu_text.show()
	control_button.grab_focus()


func _on_back_to_title_button_pressed() -> void:
	controls_locked = true
	Global.save_settings()
	Main.change_scene(title_screen)
