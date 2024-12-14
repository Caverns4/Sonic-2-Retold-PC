extends Node2D
var getCam = null
var player = null
var winner = Global.CHARACTERS.NONE

var triggers = []

@onready var screenXSize = GlobalFunctions.get_screen_size().x

func _physics_process(_delta):
	# check if player.x position is greater then the post
	# Global.players[0].global_position.y <= global_position.y and
	if Global.TwoPlayer:
		TriggerSignpostMultiPlayer()
	else:
		TriggerSignpostSinglePlayer()
	
	if !Global.TwoPlayer:
		InitEndOfAct()
		# stage clear settings
		if Global.stageClearPhase != 0:
			# lock camera to self
			if getCam:
				getCam.global_position.x = global_position.x
			# if player greater then screen and stage clear phase is 2 then activate the stage clear sequence
			if player:
				if player.global_position.x > global_position.x+(screenXSize/2) and player.movement.x >= 0 and Global.stageClearPhase == 2:
					# stage clear won't work is stage clear phase isn't 0
					Global.stageClearPhase = 0
					Global.stage_clear()
					# set stage clear to 3, this will activate the HUD sequence
					Global.stageClearPhase = 3

func TriggerSignpostMultiPlayer():
	for i in Global.players.size():
		if Global.players[i].global_position.x > global_position.x and Global.stageClearPhase == 0:
			player = Global.players[i]
	if player and !triggers.has(player):
		triggers.append(player)
		# Camera limit set
		player.limitLeft = global_position.x -screenXSize/2
		player.limitRight = global_position.x +(screenXSize/2)+64
		getCam = player.camera
		
		if !winner:
			winner = player.character
		
		SetSignpostAnimation(winner)
		if triggers.size() > 1:
			$Timer.start()
		

func TriggerSignpostSinglePlayer():
	if Global.players[0].global_position.x > global_position.x and Global.stageClearPhase == 0:
		# set player variable
		player = Global.players[0]
		# Camera limit set
		player.limitLeft = global_position.x -screenXSize/2
		player.limitRight = global_position.x +(screenXSize/2)+64
		getCam = player.camera
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
		player.playerControl = -1
		# put states under player in here if the state could end up getting the player soft locked
		var stateCancelList = [player.STATES.WALLCLIMB]
		for i in stateCancelList:
			if i == player.currentState:
				player.set_state(player.STATES.AIR)
		if !Global.TwoPlayer:
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
	#Set flag to load the results screen.
