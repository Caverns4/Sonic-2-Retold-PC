extends Node

# Music
var musicParent = null
var music: AudioStreamPlayer = null
var life: AudioStreamPlayer = null


var startVolumeLevel = 0 # used as reference for when a volume change started
var setVolumeLevel = 0 # where to fade the volume to
var volume_fade_amount = 0 # current stage between start and set for volume level
var volumeFadeSpeed = 1 # speed for volume changing

# index for current theme
var currentTheme = 0
# The Audio Resource that is the currently playing song.
# Used to avoid the same song being queued twice,
# unless the queue request is agnostic.
var currentMusic = null
# song themes to play for things like invincibility and speed shoes

enum THEME{NORMAL,INVINCIBLE,SPEED,SUPER,BOSS,DROWN,RESULTS}
var themes = [
	null, # Level Music
	preload("res://Audio/Soundtrack/s2br_Invincible.ogg"), # INVINCIBLE
	preload("res://Audio/Soundtrack/s2br_SuperSonic.ogg"), # SPEED
	preload("res://Audio/Soundtrack/s2br_SuperSonic2.ogg"), # SUPER
	preload("res://Audio/Soundtrack/s2br_Boss.ogg"), # BOSS
	preload("res://Audio/Soundtrack/s2br_drowning.ogg"), #DROWN
	preload("res://Audio/Soundtrack/s2br_Result.ogg")] # RESULTS

# Sound, used for play_sound (used for a global sound, use this if multiple nodes use the same sound)
var soundChannel = AudioStreamPlayer.new()
#Alternate global Sound player
var soundChannel2 = AudioStreamPlayer.new()

## Emitted once a volume fade function is complete.
signal volume_set

func _ready() -> void:
	# set sound settings
	add_child(soundChannel)
	soundChannel.bus = "SFX"
	add_child(soundChannel2)
	soundChannel2.bus = "SFX"
	volume_set.connect(On_volume_set)

func _process(delta):
	if !get_tree().paused and !music.stream_paused:
		# check that volume lerp isn't transitioned yet
		if volume_fade_amount < 1:
			# move volume lerp to 1
			volume_fade_amount = move_toward(volume_fade_amount,1,delta*volumeFadeSpeed)
			# use volume lerp to set the effect volume
			SoundDriver.music.volume_db = lerp(float(startVolumeLevel),float(setVolumeLevel),float(volume_fade_amount))
			if volume_fade_amount >= 1:
				emit_signal("volume_set")

# use this to play a sound globally, use load("res:..") or a preloaded sound
func play_sound(sound = null):
	if sound != null:
		soundChannel.stream = sound
		soundChannel.play()

func play_sound2(sound = null):
	if sound != null:
		soundChannel2.stream = sound
		soundChannel2.play()

#Logically pick which song should be picked.
func playNormalMusic():
	# Heirarchy:
	# Assume theme is 0 by default
	
	if Global.stageClearPhase > 0:
		return
	
	currentTheme = THEME.NORMAL # Assume normal level Theme
	for i in Global.players:
		if i.shoeTime > 0 and currentTheme == THEME.NORMAL:
			currentTheme = THEME.SPEED
		if i.supTime > 0:
			if !i.isSuper:
				if currentTheme != THEME.SUPER:
					currentTheme = THEME.INVINCIBLE
			else:
				currentTheme = THEME.SUPER #Boss theme unless Super

	if Global.fightingBoss:
		if !Global.players[0].isSuper:
			currentTheme = THEME.BOSS #Boss theme unless Super
		else:
			currentTheme = THEME.SUPER #Boss theme unless Super
	playMusic(themes[currentTheme],false)

## Play Arg1, unless it matches the current song and arg2 is false.
func playMusic(musID = null,agnostic = false):
	#If agnostic is set, the song is queued even if the same song is playing.
	if musID and (musID != currentMusic) or (agnostic):
		SoundDriver.music.stream = musID
		SoundDriver.music.play()
		currentMusic = musID

func playExtraLifeMusic():
	music.stream_paused = true
	music.volume_db = -100
	life.stop()
	life.play()
	await life.finished
	music.stream_paused = false
	set_volume(1.0,0.5)

# set the volume level
func set_volume(final_volume: float = 0, fade_speed: float = 1):
	print("SetVolumeCall")
	# set the start volume level to the curren volume
	startVolumeLevel = music.volume_db
	# set the volume level to go to
	setVolumeLevel = final_volume
	# set volume transition
	volume_fade_amount = 0
	# set the speed for the transition
	volumeFadeSpeed = fade_speed
	# this is continued in _process() as it needs to run during gameplay

func reset_volume():
	print("HardVolumeReset")
	# stop life sound (if it's still playing)
	if SoundDriver.life.is_playing():
		SoundDriver.life.stop()
		# set volume level to default
	music.volume_db = 0
	startVolumeLevel = 0


func On_volume_set():
	pass
