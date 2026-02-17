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
## Last saved menu button
var menu_option: Button = null

## clamp for minimum and maximum sound volume
var clampSounds = [-40.0,6.0]
## how much to iterate through (take the total sum then divide it by how many steps we want)
@onready var soundStep = (abs(clampSounds[0])+abs(clampSounds[1]))/100.0


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

func _on_sfx_volume_button_pressed() -> void:
	menu_option = sfx_volume_button
	set_control_lock_state(true)
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
	set_control_lock_state(false)
	sfx_volume_button.grab_focus()

func _on_music_volume_button_pressed() -> void:
	menu_option = music_volume_button
	set_control_lock_state(true)
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
	set_control_lock_state(false)
	music_volume_button.grab_focus()


func _on_crt_filter_button_pressed() -> void:
	menu_option = crt_filter_button
	Main.crt_filter.visible = !Main.crt_filter.visible
	crt_filter_button.text = "Crt Filter:      " + Global.on_off[int(Main.crt_filter.visible)]


func _on_aspect_ratio_button_pressed() -> void:
	menu_option = aspect_ratio_button
	Global.aspectRatio = wrapi(Global.aspectRatio+1,0,Global.aspectResolutions.size())
	#if !Global.IsFullScreen():
	Global.SetupWindowSize()
	#else:
	#	var resolution = Global.aspectResolutions[Global.aspectRatio]
	#	get_window().content_scale_size = Vector2i(resolution.x*Global.zoomSize, resolution.y*Global.zoomSize)
	aspect_ratio_button.text = "Aspect Ratio:    " + Global.aspect_strings[int(Global.aspectRatio)]


func _on_scale_button_pressed() -> void:
	menu_option = scale_button
	set_control_lock_state(true)
	var sfx_menu: SliderPopUpMenu = slider_menu_scene.instantiate()
	sfx_menu.initial_value = Global.zoomSize
	sfx_menu.min_slider_value = 1
	sfx_menu.max_slider_value = 5
	sfx_menu.title = "Scale:"
	add_child(sfx_menu)
	var new_scale = await sfx_menu.menu_exit
	Global.zoomSize = new_scale
	if (
		(get_window().mode != Window.MODE_EXCLUSIVE_FULLSCREEN) and 
		(get_window().mode != Window.MODE_FULLSCREEN)):
			get_window().set_size(get_viewport().get_visible_rect().size*Global.zoomSize)
	set_control_lock_state(false)
	scale_button.text = "scale:" + (str(int(Global.zoomSize))+"x")
	scale_button.grab_focus()



func _on_fullscreen_button_pressed() -> void:
	menu_option = full_screen_button
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
	var onoff: String = Global.on_off[int(((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)))]
	full_screen_button.text = "Full Screen: " + onoff


func _on_controls_button_pressed() -> void:
	menu_option = control_button
	Global.save_settings()
	set_control_lock_state(true)
	menu_text.hide()
	Main.control_menu.visible = true
	get_tree().paused = true
	
	set_control_lock_state(false)
	menu_text.show()
	control_button.grab_focus()


func _on_back_to_title_button_pressed() -> void:
	menu_option = quit_button
	set_control_lock_state(true)
	Global.save_settings()
	Main.change_scene(title_screen)

func set_control_lock_state(state: bool):
	for i in menu_text.get_children():
		if i.has_signal("pressed"):
			i.disabled = state
	if menu_option.disabled == false:
		await get_tree().process_frame
		menu_option.grab_focus()
