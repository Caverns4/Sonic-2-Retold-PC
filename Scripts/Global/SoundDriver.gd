extends Node

# Music
var musicParent = null
var music: AudioStreamPlayer = null
var drowning: AudioStreamPlayer = null
var life: AudioStreamPlayer = null

# index for current theme
var currentTheme = 0
# The Audio Resource that is the currently playing song.
# Used to avoid the same song being queued twice,
# unless the queue request is agnostic.
var currentMusic = null
# song themes to play for things like invincibility and speed shoes

enum THEME{NORMAL,INVINCIBLE,SPEED,SUPER,BOSS,RESULTS}
var themes = [
	null, # Level Music
	preload("res://Audio/Soundtrack/s2br_Invincible.ogg"), # INVINCIBLE
	preload("res://Audio/Soundtrack/s2br_SuperSonic.ogg"), # SPEED
	preload("res://Audio/Soundtrack/s2br_SuperSonic2.ogg"), # SUPER
	preload("res://Audio/Soundtrack/s2br_Boss.ogg"), # BOSS
	preload("res://Audio/Soundtrack/s2br_Result.ogg")] # RESULTS

# Sound, used for play_sound (used for a global sound, use this if multiple nodes use the same sound)
var soundChannel = AudioStreamPlayer.new()
#Alternate global Sound player
var soundChannel2 = AudioStreamPlayer.new()


func _ready() -> void:
	# set sound settings
	add_child(soundChannel)
	soundChannel.bus = "SFX"
	add_child(soundChannel2)
	soundChannel2.bus = "SFX"


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
