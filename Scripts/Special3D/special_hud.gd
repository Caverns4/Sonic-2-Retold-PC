extends CanvasLayer

@onready var message = $Center/TextMessage


var resultsScreen = preload("res://Scene/SpecialStage/SpecialStageResult.tscn")
var messageTime = 3.0
var message_text: String = ""
var ring_requirment: int = 40

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.hud = self
	message_text = "GET " + str(ring_requirment) + " RINGS"
	if !Global.PlayerChar2 or !Global.two_player_mode:
		$TopRight.queue_free()
		$TopLeft.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	messageTime -= delta
	if message.visible and messageTime <= 0.0:
		ClearMessage()
	
	if Global.special_stage_players.size() > 1:
		$TopLeft/RingCountP1.text = str(min(Global.special_stage_players[0].rings,999))
		$TopRight/RingCountP2.text = str(min(Global.special_stage_players[1].rings,999))
		var RingTotal = min((Global.special_stage_players[0].rings + Global.special_stage_players[1].rings),999)
		$TopCenter/RingCount.text = str(RingTotal).lpad(3," ")
	else:
		$TopCenter/RingCount.text = str(min(Global.special_stage_players[0].rings,999)).lpad(4," ")

func _physics_process(delta: float) -> void:
	message.text = message_text

func ShowThumbsUp():
	$Center/Banner.visible = true
	$Center/BannerThumb.visible = true
	
	await get_tree().create_timer(2.0).timeout
	$Center/Banner.visible = false
	$Center/BannerThumb.visible = false

func ClearMessage():
	message.visible = false
	

func endStage():
	await Global.life.finished
	Global.main.change_scene_to_file(resultsScreen,"WhiteOut","WhiteOut",1,false,false)
