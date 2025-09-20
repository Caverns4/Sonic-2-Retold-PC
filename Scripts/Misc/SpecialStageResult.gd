extends Node2D


var zone_loader = preload("res://Scene/Presentation/ZoneLoader.tscn")

enum STATE{IDLE,COUNTDOWN,SHOWTEXT,WAITTOEXIT,EXITING}
var state: STATE = STATE.IDLE
var state_timer = 1.0
var ring_bonus: int = 0
var gems_bonus: int = 0
var total: int = 0

var flicker_time = 0.01

@onready var ring_counter = %RingScore
@onready var gem_counter = %GemScore
@onready var total_text = %TotalScore


func _ready():
	$HUD/CounterWait.start()
	ring_bonus = Global.special_stage_rings*10
	if Global.lastSpecialStageResult:
		Global.specialStageID += 1
		gems_bonus = 50000
	
	# $HUD/Stage.text = "Stage "+str(Global.specialStageID+1)
	# cycle through emeralds on the hud
	for i in $HUD/ColorRect.get_child_count():
		$HUD/ColorRect.get_child(i).visible = (Global.emeralds & (1 << i))
	SpecialResults_SetupText()
	var currentTheme = SoundDriver.themes[SoundDriver.THEME.RESULTS]
	SoundDriver.playMusic(currentTheme)

func _process(delta: float) -> void:
	state_timer -= delta
	#Update inline state
	match state:
		STATE.COUNTDOWN:
			if state_timer <= 0.0:
				state_timer = 0.025
				$HUD/CounterSFX.play()
				if ring_bonus > 0:
					if ring_bonus > 100:
						ring_bonus -= 100
						Global.check_score_life(100)
						Global.score += 100
						total += 100
					else:
						ring_bonus -= 10
						Global.check_score_life(10)
						Global.score += 10
						total += 10
				elif gems_bonus > 0:
					if gems_bonus > 100:
						gems_bonus -= 100
						Global.check_score_life(100)
						Global.score += 100
						total += 100
					else:
						gems_bonus -= 10
						Global.check_score_life(10)
						Global.score += 10
						total += 10
				else:
					$HUD/CounterSFX.stop()
					$HUD/Score.play()
					state_timer = 1.0
					state = STATE.SHOWTEXT
		STATE.SHOWTEXT:
			state = STATE.WAITTOEXIT
		STATE.WAITTOEXIT:
			if !SoundDriver.music.playing and state_timer <= 0.0:
				state = STATE.EXITING
				$Emerald.play()
				returnToLevel()

	ring_counter.text = str(int(ring_bonus))
	gem_counter.text = str(int(gems_bonus))
	total_text.text = str(int(total))

func _physics_process(delta: float) -> void:
	flicker_time -= delta
	if flicker_time <= 0.0:
		flicker_time = 0.01
		$HUD/ColorRect.visible = !$HUD/ColorRect.visible

func returnToLevel():
	#Wipe some data to avoid contamination.
	Global.lastSpecialStageResult = false
	Global.special_stage_rings = 0
	Global.special_stage_players.clear()
	
	if Global.stageInstanceMemory:
		Global.main.change_scene_to_file(null,"WhiteOut","WhiteOut",1,true,false)
	else:
		Global.main.change_scene_to_file(zone_loader,"WhiteOut","WhiteOut",1,false,true)

func SpecialResults_SetupText():
	if !Global.lastSpecialStageResult:
		$HUD/ResultLabel/SonicGot.text = "CHAOS EMERALDS"
		$HUD/ResultLabel/Through.text = ""
	else:
		$HUD/ResultLabel/SonicGot.text = Global.characterNames[Global.PlayerChar1-1]
		$HUD/ResultLabel/SonicGot.text += " GOT"
		
		if Global.emeralds >= 127:
			$HUD/ResultLabel/Through.text = "THEM ALL"
	$HUD/ResultLabel.visible = true

func SuperText():
	var charName = str(Global.characterNames[Global.PlayerChar1-1])
	$HUD/ResultLabel/SonicGot.text = "NOW " + charName + " CAN BE"
	$HUD/ResultLabel/Through.text = "SUPER " + charName
	
	await get_tree().create_timer(2.0)


func _on_counter_wait_timeout() -> void:
	state = STATE.COUNTDOWN
	state_timer = 0.0
