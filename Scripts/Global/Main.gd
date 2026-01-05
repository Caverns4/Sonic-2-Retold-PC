class_name MainGameScene
extends CanvasLayer

## Emited when the scene fades, used to load in level details and data to hide it from the player
signal scene_faded
## If the game can be paused in its current state
var can_pause = false

@onready var input_view: Control = $GUI/ControlMap
@onready var crt_filter: ColorRect = $CanvasLayer/ColorRect
@onready var control_menu: CanvasLayer = $GUI/ControllerMenu

func _ready():
	# Sound Driver object references
	SoundDriver.musicParent = get_node_or_null("Music")
	SoundDriver.music = get_node_or_null("Music/Music")
	SoundDriver.life = get_node_or_null("Music/Life")
	scene_faded.connect(On_scene_faded)

func _input(event):
	# Pausing
	if (event.is_action_pressed("gm_pause") and can_pause) or (
		event.is_action_pressed("gm_pause_P2") and can_pause and Global.two_player_mode):
		# check if the game wasn't paused and the tree isn't paused either
		if !get_tree().paused:
			get_tree().paused = true
			$GUI/Pause.visible = true
		# else if the scene was paused manually and the game was paused, check that the gui menu isn't visible and unpause
		# Note: the gui menu has some settings to unpause itself so we don't want to override that while the user is in the settings
		elif get_tree().paused and !$GUI/Pause.visible:
			get_tree().paused = false
	if Input.is_action_just_pressed("ui_control_menu") and !get_tree().paused:
		get_tree().paused = true
		control_menu.show()


	# reset game if F2 is pressed (this button can be changed in project settings)
	if event.is_action_pressed("ui_reset"):
		reset_game()
	


# reset game function
func reset_game():
	$GUI/Pause.visible = false
	# Godot doesn't like returning values with empty variables so create a dummy variable for it to assign
	change_scene("res://Scene/Presentation/Title.tscn","FadeOut",1.0,true)

## New Scene Change function.Args: Scene path, fade animation, time of transition, clear data
func change_scene(scene: String, fade_anim: String = "FadeOut", length: float = 1.0, resetData:bool = true):
	$GUI/Fader.speed_scale = 1.0/float(length)
	# if fadeOut isn't blank, play the fade out animation and then wait, otherwise skip this
	if fade_anim != "":
		$GUI/Fader.queue(fade_anim)
		await $GUI/Fader.animation_finished
	# error prevention
	emit_signal("scene_faded")
	await get_tree().process_frame
	if scene:
		get_tree().change_scene_to_file(scene)
	else:
		get_tree().reload_current_scene()
	# reset data level data, if reset data is true
	if resetData:
		Global.reset_level_data()
	else:
		Global.Clean_Up_Object_References()
	# play fade in animation back if it's not blank
	if fade_anim != "":
		$GUI/Fader.play_backwards(fade_anim)
	SoundDriver.reset_volume()

# set the volume level. All this does is push a request to the Sound Driver.
func set_volume(final_volume: float = 0, fade_speed: float = 1):
	SoundDriver.set_volume(final_volume,fade_speed)

func On_scene_faded():
	pass
