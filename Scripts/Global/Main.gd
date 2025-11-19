class_name MainGameScene
extends Node2D

# last scene is used for referencing the current scene (this is used for stage restarting)
var lastScene = null

# this gets emited when the scene fades, used to load in level details and data to hide it from the player
signal scene_faded
# signal that emits when volume fades
signal volume_set

# note: volumes can be set with set_volume(), these variables are just for volume control reference
var startVolumeLevel = 0 # used as reference for when a volume change started
var setVolumeLevel = 0 # where to fade the volume to
var volumeLerp = 0 # current stage between start and set for volume level
var volumeFadeSpeed = 1 # speed for volume changing

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
	volume_set.connect(On_volume_set)

func _process(delta):
	# verify scene isn't paused
	if !get_tree().paused and SoundDriver.music != null:
		# pause main music if Extra Life song is playing
		SoundDriver.music.stream_paused = (SoundDriver.life.playing)
		
		# check that volume lerp isn't transitioned yet
		if volumeLerp < 1:
			# move volume lerp to 1
			volumeLerp = move_toward(volumeLerp,1,delta*volumeFadeSpeed)
			# use volume lerp to set the effect volume
			SoundDriver.music.volume_db = lerp(float(startVolumeLevel),float(setVolumeLevel),float(volumeLerp))
			#SoundDriver.music.volume_db = SoundDriver.music.volume_db
			if volumeLerp >= 1:
				emit_signal("volume_set")

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
	Global.keep_memory.clear()
	# reset game values
	Global.reset_values()
	# Godot doesn't like returning values with empty variables so create a dummy variable for it to assign
	change_scene("res://Scene/Presentation/Title.tscn")

## New Scene Change function.
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
		Global.players.clear()
		Global.special_stage_players.clear()
		Global.checkPoints.clear()
		Global.hud = null
		Global.waterLevel = null
		Global.gameOver = false
		if Global.stageClearPhase != 0:
			Global.currentCheckPoint = -1
			Global.levelTime = 0
			Global.levelTimeP2 = 0
			Global.timerActive = false
			Global.timerActiveP2 = false
		Global.globalTimer = 0
		Global.stageClearPhase = 0
	# play fade in animation back if it's not blank
	if fade_anim != "":
		$GUI/Fader.play_backwards(fade_anim)
	# stop life sound (if it's still playing)
	if SoundDriver.life.is_playing():
		SoundDriver.life.stop()
		# set volume level to default
	SoundDriver.music.volume_db = SoundDriver.music.volume_db

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
	get_tree().reload_current_scene()
	# play fade in animation back if it's not blank
	if fade_anim != "":
		$GUI/Fader.play_backwards(fade_anim)

func load_saved_scene():
	if Global.stageInstanceMemory:
		var prev = get_tree().root.get_child(0)
		prev.queue_free()
		get_tree().root.add_child(Global.stageInstanceMemory)
		Global.stageInstanceMemory = null
		print("Did this work?")
	else:
		print("No valid scene to call back from!")
		reset_game()

# executed when life sound has finished
func _on_Life_finished():
	# set volume level to default
	set_volume()

# set the volume level
func set_volume(volume = 0, fadeSpeed = 1):
	# set the start volume level to the curren volume
	startVolumeLevel = SoundDriver.music.volume_db
	# set the volume level to go to
	setVolumeLevel = volume
	# set volume transition
	volumeLerp = 0
	# set the speed for the transition
	volumeFadeSpeed = fadeSpeed
	# this is continued in _process() as it needs to run during gameplay

func On_scene_faded():
	pass

func On_volume_set():
	pass
