class_name MainGameScene
extends Node2D

# this gets emited when the scene fades, used to load in level details and data to hide it from the player
signal scene_faded
# was paused enables menu control when the player pauses manually so they don't get stuck (get_tree().paused may want to be used by other intances)
var wasPaused = false
# determines if the current scene can pause
var sceneCanPause = false

func _ready():
	# global object references
	Global.main = self
	SoundDriver.musicParent = get_node_or_null("Music")
	SoundDriver.music = get_node_or_null("Music/Music")
	SoundDriver.life = get_node_or_null("Music/Life")
	# initialize game data using global reset (it's better then assigning variables twice)
	Global.reset_values()
	scene_faded.connect(On_scene_faded)

func _input(event):
	# Pausing
	if (event.is_action_pressed("gm_pause") and sceneCanPause) or (
		event.is_action_pressed("gm_pause_P2") and sceneCanPause and Global.two_player_mode):
		# check if the game wasn't paused and the tree isn't paused either
		if !wasPaused and !get_tree().paused:
			# Do the pause
			wasPaused = true
			get_tree().paused = true
			$GUI/Pause.visible = true
		# else if the scene was paused manually and the game was paused, check that the gui menu isn't visible and unpause
		# Note: the gui menu has some settings to unpause itself so we don't want to override that while the user is in the settings
		elif wasPaused and get_tree().paused and !$GUI/Pause.visible:
			# Do the unpause
			wasPaused = false
			get_tree().paused = false

	# reset game if F2 is pressed (this button can be changed in project settings)
	if event.is_action_pressed("ui_reset"):
		reset_game()

# reset game function
func reset_game():
	$GUI/Pause.visible = false
	# remove the was paused check
	wasPaused = false
	# reset game values
	Global.reset_values()
	# Godot doesn't like returning values with empty variables so create a dummy variable for it to assign
	change_scene("res://Scene/Presentation/Title.tscn")

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
	get_tree().change_scene_to_file(scene)
	# reset data level data, if reset data is true
	if resetData:
		Global.reset_level_data()
	# play fade in animation back if it's not blank
	if fade_anim != "":
		$GUI/Fader.play_backwards(fade_anim)
	# stop life sound (if it's still playing)
	if SoundDriver.life.is_playing():
		SoundDriver.life.stop()
		# set volume level to default
	set_volume(1.0,0.01)

func Reload_Level(fade_anim = "FadeOut",length = 1.0):
	$GUI/Fader.speed_scale = 1.0/float(length)
	# if fadeOut isn't blank, play the fade out animation and then wait, otherwise skip this
	if fade_anim != "":
		$GUI/Fader.queue(fade_anim)
		await $GUI/Fader.animation_finished
	# error prevention
	emit_signal("scene_faded")
	await get_tree().process_frame
	Global.Clean_Up()
	Global.nodeMemory.clear()
	get_tree().reload_current_scene()
	# play fade in animation back if it's not blank
	if fade_anim != "":
		$GUI/Fader.play_backwards(fade_anim)

# set the volume level. All this does is push a request to the Sound Driver.
func set_volume(final_volume: float = 0, fade_speed: float = 1):
	SoundDriver.set_volume(final_volume,fade_speed)

func On_scene_faded():
	pass
