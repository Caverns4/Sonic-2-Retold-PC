extends CanvasLayer

@onready var message = $Center/TextMessage

var resultsScreen = preload("res://Scene/SpecialStage/SpecialStageResult.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.hud = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	$TopLeft/RingCountP1.text = str(min(Global.special_stage_players[0].rings,999))
	if Global.special_stage_players.size() > 1:
		$TopRight/RingCountP2.text = str(min(Global.special_stage_players[1].rings,999))
		
		var RingTotal = min((Global.special_stage_players[0].rings + Global.special_stage_players[1].rings),999)
		
		$TopCenter/RingCount.text = str(RingTotal).lpad(3," ")
	

func endStage():
	await Global.life.finished
	Global.main.change_scene_to_file(resultsScreen,"WhiteOut","WhiteOut",1,false,false)
