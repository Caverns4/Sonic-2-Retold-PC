extends Node2D
var getCam = null
var player = null

@onready var screenXSize = GlobalFunctions.get_screen_size().x

func _physics_process(_delta):
	# check if player.x position is greater then the post
	# Global.players[0].global_position.y <= global_position.y and
	if Global.TwoPlayer == false:
		TriggerSignpostSinglePlayer()
	else:
		TriggerSignpostSinglePlayer() #Temp
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

func TriggerSignpostSinglePlayer():
	if Global.players[0].global_position.x > global_position.x and Global.stageClearPhase == 0:
		# set player variable
		player = Global.players[0]
	
		# Camera limit set
		player.limitLeft = global_position.x -screenXSize/2
		player.limitRight = global_position.x +(screenXSize/2)+64
		getCam = player.camera
	
		# play spinner
		$Signpost/Animator.play("Spinner")
		match player.character:
			1:
				$Signpost/Animator.queue("Tails")
			2:
				$Signpost/Animator.queue("Knuckles")
			3:
				$Signpost/Animator.queue("Mighty")
			4:
				$Signpost/Animator.queue("Ray")
			_:
				$Signpost/Animator.queue("Sonic")
		
		$Signpost/GoalPost.play()
		# set global stage clear phase to 1, 1 is used to stop the timer (see HUD script)
		Global.stageClearPhase = 1
		
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
		# set inputs to right
		player.inputs[player.INPUTS.XINPUT] = 1
		player.inputs[player.INPUTS.YINPUT] = 0
		player.inputs[player.INPUTS.ACTION] = 0
		# make partner move too
		if player.get("partner") != null:
			player.partner.inputs[player.INPUTS.XINPUT] = 1
			player.partner.inputs[player.INPUTS.YINPUT] = 0
			player.partner.inputs[player.INPUTS.ACTION] = 0
