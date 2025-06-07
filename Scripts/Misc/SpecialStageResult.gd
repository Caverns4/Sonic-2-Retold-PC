extends Node2D

var activated = false
var state_timer = 1.0

func _ready():
	#Wipe the player array to avoide contamination.
	Global.special_stage_players = []
	# set stage text label to the current stage
	$HUD/Stage.text = "Stage "+str(Global.specialStageID+1)
	# cycle through emeralds on the hud
	for i in $HUD/ColorRect.get_child_count():
		$HUD/ColorRect.get_child(i).visible = (Global.emeralds & (1 << i))
	SpecialResults_SetupText()
	if Global.lastSpecialStageResult:
		Global.specialStageID += 1
	Global.stage_clear()
	print(Global.emeralds)

func _process(delta: float) -> void:
	if !Global.music.playing and !activated:
		activated = true
		returnToLevel()

func returnToLevel():
	Global.lastSpecialStageResult = false
	Global.main.change_scene_to_file(null,"WhiteOut","WhiteOut",1,true,false)

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
	
