extends Node2D

@export var multiplayerOnly: bool = false
var two_player_results: String = "res://Scene/Presentation/TwoPlayerResults.tscn"
var camera: Camera2D = null
var player: Player2D = null
var winner: Global.CHARACTERS = Global.CHARACTERS.NONE

var triggers: Array[Player2D] = []

@onready var screenXSize = GlobalFunctions.get_screen_size().x

func _ready() -> void:
	if multiplayerOnly and !Global.two_player_mode:
		queue_free()

func _physics_process(_delta):
	# check if player.x position is greater then the post
	# Global.players[0].global_position.y <= global_position.y and
	if Global.two_player_mode:
		TriggerSignpostMultiPlayer()
	else:
		TriggerSignpostSinglePlayer()
	
	if !Global.two_player_mode:
		InitEndOfAct()
		# stage clear settings
		if Global.stageClearPhase != 0:
			# lock camera to self
			if camera:
				camera.global_position.x = global_position.x
			# if player greater then screen and stage clear phase is 2 then activate the stage clear sequence
			if player:
				if player.global_position.x > global_position.x+(screenXSize/2) and player.movement.x >= 0 and Global.stageClearPhase == 2:
					var currentTheme = SoundDriver.themes[SoundDriver.THEME.RESULTS]
					SoundDriver.playMusic(currentTheme)
					# set stage clear to 3, this will activate the HUD sequence
					Global.stageClearPhase = 3

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
				$Timer.start()
		

func TriggerSignpostSinglePlayer():
	if !Global.players:
		return
	
	if Global.players[0].global_position.x > global_position.x and Global.stageClearPhase == 0:
		Main.can_pause = false
		# set player variable
		player = Global.players[0]
		# Camera limit set
		for i in Global.players:
			i.limitLeft = global_position.x -screenXSize/2
			i.limitRight = global_position.x +(screenXSize/2)+64
		camera = player.camera
		SetSignpostAnimation(player.character)
		# set global stage clear phase to 1, 1 is used to stop the timer (see HUD script)
		Global.stageClearPhase = 1

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


func InitEndOfAct():
	if Global.stageClearPhase == 1 and player:
		# wait for spinner to finish
		await $Signpost/Animator.animation_finished
		# after finishing spin, set stage clear to 2 and disable the players controls,
		# stage clear is set to 2 so that the level ending doesn't start prematurely but we can track where the player is
		Global.stageClearPhase = 2
		for i in Global.players:
			i.playerControl = -1
		# put states under player in here if the state could end up getting the player soft locked
		var stateCancelList = [player.STATES.WALLCLIMB]
		for i in stateCancelList:
			if i == player.currentState:
				player.set_state(player.STATES.AIR)
		# set inputs to right
		player.inputs[player.INPUTS.XINPUT] = 1
		player.inputs[player.INPUTS.YINPUT] = 0
		player.inputs[player.INPUTS.ACTION] = 0
		# make partner move too
		if player.get("partner") != null:
			player.partner.inputs[player.INPUTS.XINPUT] = 1
			player.partner.inputs[player.INPUTS.YINPUT] = 0
			player.partner.inputs[player.INPUTS.ACTION] = 0


func _on_timer_timeout() -> void:
	var results = [Global.score,Global.levelTime,Global.players[0].rings,
	Global.scoreP2,Global.levelTimeP2,Global.players[1].rings]
	Global.twoPlayActResults.append(results)
	Main.change_scene(two_player_results)
