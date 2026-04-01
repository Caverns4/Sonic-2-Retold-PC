extends Node2D

@export var multiplayerOnly: bool = false
var two_player_results: String = "res://Scene/Presentation/TwoPlayerResults.tscn"
var camera: Camera2D = null
var player: Player2D = null
var winner: Global.CHARACTERS = Global.CHARACTERS.NONE

var triggers: Array[Player2D] = []

enum STATE{IDLE,SPINNING,MOVE_RIGHT,NULL}
var state: int = 0

@onready var screenXSize: float = GlobalFunctions.get_screen_size().x

func _ready() -> void:
	if multiplayerOnly and !Global.two_player_mode:
		queue_free()

func _physics_process(_delta: float) -> void:
	match state:
		STATE.IDLE:
			#Await trigger
			_check_players()
		STATE.SPINNING:
			pass
		STATE.MOVE_RIGHT:
			if player.global_position.x > global_position.x+(screenXSize/2):
				Global.emit_stage_clear()

func _check_players() -> void:
	if Global.two_player_mode:
		for playerObj:Player2D in Global.players:
			if !triggers.has(playerObj) and playerObj.global_position.x > global_position.x:
				triggers.append(playerObj)
				if !winner:
					winner = playerObj.character as Global.CHARACTERS
					$Signpost/GoalPost2P.play()
	else:
		if Global.players[0].global_position.x > global_position.x:
			state = STATE.SPINNING
			player = Global.players[0]
			# Camera limit set
			for playerObj: Player2D in Global.players:
				playerObj.limitLeft = int(global_position.x -screenXSize/2)
				playerObj.limitRight = int(global_position.x +(screenXSize/2))+64
				playerObj.camera_limits_target[0] = global_position.x -screenXSize/2
				playerObj.camera_limits_target[2] = global_position.x +(screenXSize/2)
				playerObj.camera_shift_time = 1.0
			camera = player.camera
			player.camLockTime = 4096.0
			SetSignpostAnimation(player.character)

func TriggerSignpostMultiPlayer() -> void:
	for playerObj:Player2D in Global.players:
		if (playerObj.global_position.x > global_position.x and
		!triggers.has(playerObj)):
			triggers.append(playerObj)
			var index: int = Global.players.find(playerObj)
			# Camera limit set
			playerObj.limitLeft = int(global_position.x - screenXSize/2)
			playerObj.limitRight = int(global_position.x +(screenXSize/2))
			playerObj.camera_limits_target[0] = global_position.x -screenXSize/2
			playerObj.camera_limits_target[2] = global_position.x +(screenXSize/2)
			playerObj.camera_shift_time = 1.0
		
			if !winner:
				winner = playerObj.character as Global.CHARACTERS
				$Signpost/GoalPost2P.play()
		
			SetSignpostAnimation(winner)
			if index == 0:
				Global.timerActive = false
			else:
				Global.timerActiveP2 = false
			for i in Global.players.size():
				if i != index and Global.hud:
					Global.hud.InitTimerForPlayer(i)
		
			if triggers.size() >= Global.players.size():
				Main.can_pause = false
				$TwoPlayerTimer.start()

func SetSignpostAnimation(character: Global.CHARACTERS) -> void:
		# play spinner
		$Signpost/Animator.play("Spinner")
		match character:
			Global.CHARACTERS.TAILS:
				$Signpost/Animator.queue("Tails")
			Global.CHARACTERS.KNUCKLES:
				$Signpost/Animator.queue("Knuckles")
			Global.CHARACTERS.AMY:
				$Signpost/Animator.queue("Amy")
			Global.CHARACTERS.MIGHTY:
				$Signpost/Animator.queue("Mighty")
			Global.CHARACTERS.RAY:
				$Signpost/Animator.queue("Ray")
			_:
				$Signpost/Animator.queue("Sonic")
		$Signpost/GoalPost.play()

func _on_animator_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Spinner" and !Global.two_player_mode:
		for i: Player2D in Global.players:
			i.playerControl = -1
			i.inputs[0] = 1.0
			i.inputs[1] = 1.0
		state = STATE.MOVE_RIGHT
		## put states under player in here if the state could end up getting the player soft locked
		var stateCancelList: Array = [player.STATES.WALLCLIMB]
		for i: int in stateCancelList:
			if i == player.currentState:
				player.set_state(player.STATES.AIR)
		
		## set inputs to right
		player.inputs[player.INPUTS.XINPUT] = 1
		player.inputs[player.INPUTS.YINPUT] = 0
		player.inputs[player.INPUTS.ACTION] = 0
		## make partner move too
		if player.partner:
			player.partner.inputs[player.INPUTS.XINPUT] = 1
			player.partner.inputs[player.INPUTS.YINPUT] = 0
			player.partner.inputs[player.INPUTS.ACTION] = 0


func _on_TwoPlayerTimer_timeout() -> void:
	var results: Array = [Global.score,Global.levelTime,Global.players[0].rings,
	Global.scoreP2,Global.levelTimeP2,Global.players[1].rings]
	Global.twoPlayActResults.append(results)
	await Main.change_scene(two_player_results)
