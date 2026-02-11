extends Node2D

@export var multiplayerOnly: bool = false
var two_player_results: String = "res://Scene/Presentation/TwoPlayerResults.tscn"
var camera: Camera2D = null
var player: Player2D = null
var winner: Global.CHARACTERS = Global.CHARACTERS.NONE

var triggers: Array[Player2D] = []

## TODO
enum STATE{IDLE,SPINNING,MOVE_RIGHT,NULL}
var state: int = 0

@onready var screenXSize = GlobalFunctions.get_screen_size().x

func _ready() -> void:
	if multiplayerOnly and !Global.two_player_mode:
		queue_free()

func _physics_process(_delta):
	match state:
		STATE.IDLE:
			#Await trigger
			_check_players()
		STATE.SPINNING:
			pass
		STATE.MOVE_RIGHT:
			if player.global_position.x > global_position.x+(screenXSize/2):
				Global.emit_stage_clear()

func _check_players():
	if Global.two_player_mode:
		
		for playerObj:Player2D in Global.players:
			if !triggers.has(playerObj) and playerObj.global_position.x > global_position.x:
				triggers.append(playerObj)
				#var index = Global.players.find(playerObj)
				# Camera limit set
				playerObj.limitLeft = global_position.x - screenXSize/2
				playerObj.limitRight = global_position.x + (screenXSize/2)
				## TODO: Better camera locking
				camera = playerObj.camera
				camera.global_position.x = global_position.x
				if !winner:
					winner = playerObj.character as Global.CHARACTERS
					$Signpost/GoalPost2P.play()
	else:
		if Global.players[0].global_position.x > global_position.x:
			state = STATE.SPINNING
			player = Global.players[0]
			# Camera limit set
			for i in Global.players:
				i.limitLeft = global_position.x -screenXSize/2
				i.limitRight = global_position.x +(screenXSize/2)+64
			camera = player.camera
			camera.global_position.x = global_position.x
			player.camLockTime = 4096.0
			SetSignpostAnimation(player.character)

func TriggerSignpostMultiPlayer():
	for playerObj:Player2D in Global.players:
		if (playerObj.global_position.x > global_position.x and
		!triggers.has(playerObj)):
			triggers.append(playerObj)
			var index = Global.players.find(playerObj)
			# Camera limit set
			playerObj.limitLeft = global_position.x - screenXSize/2
			playerObj.limitRight = global_position.x + (screenXSize/2)
			camera = playerObj.camera
		
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

func SetSignpostAnimation(character):
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
		for i in Global.players:
			i.playerControl = -1
		state = STATE.MOVE_RIGHT
		## put states under player in here if the state could end up getting the player soft locked
		var stateCancelList = [player.STATES.WALLCLIMB]
		for i in stateCancelList:
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
	var results = [Global.score,Global.levelTime,Global.players[0].rings,
	Global.scoreP2,Global.levelTimeP2,Global.players[1].rings]
	Global.twoPlayActResults.append(results)
	Main.change_scene(two_player_results)
