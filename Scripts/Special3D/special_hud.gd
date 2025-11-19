extends CanvasLayer

@onready var message = $Center/TextMessage
@onready var resultSound = $ResultSound
@export var success_sfx: AudioStream = preload("res://Audio/SFX/Objects/s2br_Checkpoint.wav")
@export var fail_sfx: AudioStream = preload("res://Audio/SFX/Misc/s2br_Error.wav")

enum MESSAGES{NULL,GET_RINGS,RINGS_TO_GO,NOT_ENOUGH_RINGS,GOOD,COURSE_OUT}
var message_state = MESSAGES.GET_RINGS

var resultsScreen: String = "res://Scene/SpecialStage/SpecialStageResult.tscn"
var messageTime = 3.0
var message_text: String = ""
var current_round: int = 0
var ring_requirements: Array[int] = [40,80,140]
var ring_requirement: int = 999
var total_rings: int = 0
var round_time:float = 0.0
var showed_warning_text:bool = false
var message_flash_timer:float = 0.25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.special_hud = self
	if !Global.PlayerChar2 or !Global.two_player_mode:
		$TopRight.queue_free()
		$TopLeft.queue_free()
	message_state = MESSAGES.GET_RINGS
	message.visible = true

func _physics_process(delta: float) -> void:
	var ring_total = Get_Current_Rings()
	round_time += delta
	if round_time > 30.0 and !showed_warning_text and message_state == MESSAGES.NULL:
		showed_warning_text = true
		message_state = MESSAGES.RINGS_TO_GO
		message.visible = true
	
	UpdateMessage(ring_total,delta)
	messageTime -= delta
	message.text = message_text

func Get_Current_Rings():
	total_rings = min(Global.special_stage_players[0].rings,999)
	if Global.special_stage_players.size() > 1:
		$TopLeft/RingCountP1.text = str(min(Global.special_stage_players[0].rings,999))
		$TopRight/RingCountP2.text = str(min(Global.special_stage_players[1].rings,999))
		total_rings = min((Global.special_stage_players[0].rings + Global.special_stage_players[1].rings),999)
		$TopCenter/RingCount.text = str(total_rings).lpad(4," ")
	else:
		$TopCenter/RingCount.text = str(total_rings).lpad(4," ")
	return total_rings

func UpdateMessage(_ring_total,delta):
	if !message_state:
		return
	
	match message_state:
		MESSAGES.GET_RINGS:
			if messageTime <= 0.0:
				ClearMessage()
			
			if Global.two_player_mode:
				message_text = "MOST RINGS WINS"
			else:
				message_text = "GET " + str(ring_requirement) + " RINGS!" 
		MESSAGES.RINGS_TO_GO:
			message_flash_timer -= delta
			if message_flash_timer <= 0.0:
				message_flash_timer = 0.25
				message.visible = !message.visible
			
			var to_go: int = clamp(ring_requirement - total_rings,0,ring_requirement)
			if to_go > 0:
				message_text = str(to_go) + " RINGS TO GO"
			else:
				ClearMessage()
		MESSAGES.NOT_ENOUGH_RINGS:
			message_text = "NOT ENOUGH RINGS"
		MESSAGES.GOOD:
			if messageTime <= 0.0:
				message_state = MESSAGES.GET_RINGS
				messageTime = 3.0
			match current_round:
				0:
					message_text = "NICE!"
				1:
					message_text = "GOOD!"
				69:
					message_text = "NICE!"
				_:
					message_text = "GREAT!"
		MESSAGES.COURSE_OUT:
			message_text = "COURSE OUT"
			if messageTime <= 0.0:
				messageTime = 10.0
				resultSound.stream = fail_sfx
				resultSound.play()
				endStage()

func CheckForEmerald(jingleTheme: AudioStream = null ):
	showed_warning_text = true
	var to_go: int = clamp(ring_requirement - total_rings,0,ring_requirement)
	if to_go > 0:
		message_state = MESSAGES.NOT_ENOUGH_RINGS
		message.visible = true
		messageTime = 3.0
		resultSound.stream = fail_sfx
		resultSound.play()
		endStage()
		return false
	else:
		message_state = MESSAGES.NULL
		message.visible = false
		SoundDriver.music.stop()
		resultSound.stream = jingleTheme
		resultSound.play()
		endStage()
		return true

func SetMessage(message_type: int = 0):
	if !message_type:
		var to_go: int = clamp(ring_requirement - total_rings,0,ring_requirement)
		if to_go > 0:
			message_state = MESSAGES.NOT_ENOUGH_RINGS
			message.visible = true
			messageTime = 3.0
			resultSound.stream = fail_sfx
			resultSound.play()
			endStage()
		else:
			ShowThumbsUp()
			message_state = MESSAGES.GOOD
			message.visible = true
			messageTime = 3.0
			resultSound.stream = success_sfx
			resultSound.play()
	else:
		message.visible = true
		message_state = message_type as MESSAGES
		messageTime = 3.0

func SetupNextRound(failed:bool = false):
	round_time = 0.0
	showed_warning_text = false
	if failed:
		message.visible = true
		message_state = MESSAGES.COURSE_OUT
		return
	else:
		SetMessage() #Default state prints "Good!" or "Not enough"
		current_round += 1
		var new_ring_req = 0
		if ring_requirements.size() > current_round:
			new_ring_req = ring_requirements[current_round]
		ring_requirement = new_ring_req

func ClearMessage():
	message_state = MESSAGES.NULL
	message.visible = false

func ShowThumbsUp():
	$Center/Banner.visible = true
	$Center/BannerThumb.visible = true
	
	await get_tree().create_timer(3.0).timeout
	$Center/Banner.visible = false
	$Center/BannerThumb.visible = false

func endStage():
	await resultSound.finished
	Global.main.change_scene(resultsScreen,"WhiteOut",1.0,false)
